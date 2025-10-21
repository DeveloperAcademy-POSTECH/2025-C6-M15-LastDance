//
//  ArtistReactionViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/15/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ArtistReactionViewModel: ObservableObject {
    @Published var exhibitions: [ArtistExhibitionDisplayItem] = []
    @Published var isLoading = false
    
    private let swiftDataManager = SwiftDataManager.shared
    private let exhibitionAPIService: ExhibitionAPIServiceProtocol
    private let reactionAPIService: ReactionAPIServiceProtocol
    private let artistAPIService: ArtistAPIServiceProtocol

    private var currentArtistId: Int?

    init(
        exhibitionAPIService: ExhibitionAPIServiceProtocol = ExhibitionAPIService(),
        reactionAPIService: ReactionAPIServiceProtocol = ReactionAPIService(),
        artistAPIService: ArtistAPIServiceProtocol = ArtistAPIService()
    ) {
        self.exhibitionAPIService = exhibitionAPIService
        self.reactionAPIService = reactionAPIService
        self.artistAPIService = artistAPIService
    }

    func loadArtistExhibitions() {
        isLoading = true
        exhibitions = []

        fetchCurrentArtistId { [weak self] artistId in
            guard let self = self else { return }
            if let artistId = artistId {
                self.currentArtistId = artistId
                Log.debug("Current artist ID: \(artistId)")
                self._loadArtistExhibitions(for: artistId)
            } else {
                Log.error("ID is not available, cannot load exhibitions.")
                self.isLoading = false
            }
        }
    }

    private func fetchCurrentArtistId(completion: @escaping (Int?) -> Void) {
        guard let artistUUID = UserDefaults.standard.string(
            forKey: UserDefaultsKey.artistUUID.rawValue
        ) else {
            Log.error("Artist UUID not found in UserDefaults.")
            completion(nil)
            return
        }
        Log.debug("Found Artist UUID: \(artistUUID)")

        artistAPIService.getArtistByUUID(artistUUID) { result in
            switch result {
            case .success(let artistDto):
                Log.debug("ID: \(artistDto.id)")
                completion(artistDto.id)
            case .failure(let error):
                Log.error("Failed to fetch artist by UUID: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    private func _loadArtistExhibitions(for artistId: Int) {
        exhibitionAPIService.getExhibitions(status: nil, venueId: nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let allExhibitionDtos):
                Log.debug("Fetched \(allExhibitionDtos.count) exhibitions from server.")

                let group = DispatchGroup()
                var artistParticipatingExhibitionIds: Set<Int> = []

                if allExhibitionDtos.isEmpty {
                    Log.debug("No exhibitions found from server")
                    self.isLoading = false
                    return
                }

                for exhibitionDto in allExhibitionDtos {
                    group.enter()
                    self.exhibitionAPIService.getDetailExhibition(exhibitionId: exhibitionDto.id) { detailResult in
                        switch detailResult {
                        case .success(let detailedExhibitionDto):
                            let artworksForThisExhibition =
                            self.swiftDataManager.fetchAll(Artwork.self).filter {
                                $0.exhibitionId == detailedExhibitionDto.id
                            }
                            if artworksForThisExhibition.contains(where: {
                                $0.artistId == artistId
                            }) {
                                artistParticipatingExhibitionIds.insert(detailedExhibitionDto.id)
                                Log.debug("Artist \(artistId) participates in exhibition \(detailedExhibitionDto.id).")
                            }
                        case .failure(let error):
                            Log.error("Failed. exhibition ID \(exhibitionDto.id): \(error.localizedDescription)")
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    let allLocalExhibitions = self.swiftDataManager.fetchAll(Exhibition.self)
                    let filteredExhibitions = allLocalExhibitions.filter {
                        artistParticipatingExhibitionIds.contains($0.id) && $0.isUserSelected == true
                    }
                    Log.debug("Filtered exhibitions count: \(filteredExhibitions.count)")

                    if filteredExhibitions.isEmpty {
                        Log.debug("No filtered exhibitions to display")
                        self.isLoading = false
                        return
                    }

                    self.calculateReactionCounts(for: filteredExhibitions) { updatedExhibitions in
                        self.exhibitions = updatedExhibitions.sorted { $0.exhibition.startDate > $1.exhibition.startDate }
                        Log.debug("Final exhibitions count: \(self.exhibitions.count)")
                        self.isLoading = false
                    }
                }

            case .failure(let error):
                Log.error("Failed to fetch all exhibitions: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }

    private func calculateReactionCounts(
        for exhibitions: [Exhibition],
        completion: @escaping ([ArtistExhibitionDisplayItem]) -> Void) {
        let group = DispatchGroup()
        var displayItems: [ArtistExhibitionDisplayItem] = []
        let lock = NSLock() // To protect displayItems from concurrent access

        for exhibition in exhibitions {
            group.enter()
            let artworksInExhibition =
            swiftDataManager.fetchAll(Artwork.self).filter { $0.exhibitionId == exhibition.id }
            let artworkIdsInExhibition = artworksInExhibition.map { $0.id }
            Log.debug("Exhibition \(exhibition.id) has \(artworksInExhibition.count) artworks.")

            if artworkIdsInExhibition.isEmpty {
                lock.lock()
                displayItems.append(ArtistExhibitionDisplayItem(
                    id: exhibition.id,
                    exhibition: exhibition,
                    reactionCount: 0
                ))
                lock.unlock()
                group.leave()
                continue
            }

            let innerGroup = DispatchGroup()
            var totalReactionCount = 0

            for artworkId in artworkIdsInExhibition {
                innerGroup.enter()
                reactionAPIService.getReactions(
                    artworkId: artworkId,
                    visitorId: nil,
                    visitId: nil
                ) { reactionResult in
                    switch reactionResult {
                    case .success(let reactions):
                        totalReactionCount += reactions.count
                    case .failure(let error):
                        Log.error("Failed. artwork \(artworkId): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
            }

            innerGroup.notify(queue: .main) {
                lock.lock()
                displayItems.append(ArtistExhibitionDisplayItem(id: exhibition.id, exhibition: exhibition, reactionCount: totalReactionCount))
                lock.unlock()
                Log.debug("Calculated \(totalReactionCount) reactions for exhibition \(exhibition.id).")
                group.leave()
            }
        }

        group.notify(queue: .main) {
            Log.debug("finished. Total display items: \(displayItems.count)")
            completion(displayItems)
        }
    }
}
