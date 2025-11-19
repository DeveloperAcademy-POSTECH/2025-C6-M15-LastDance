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

        let allLocalExhibitions = swiftDataManager.fetchAll(Exhibition.self)
        let filteredExhibitions = allLocalExhibitions.filter { $0.isUserSelected == true }

        if filteredExhibitions.isEmpty {
            Log.debug("No selected exhibitions to display")
            isLoading = false
            return
        }

        calculateReactionCounts(for: filteredExhibitions) { [weak self] updatedExhibitions in
            guard let self = self else { return }
            self.exhibitions = updatedExhibitions.sorted {
                $0.exhibition.startDate > $1.exhibition.startDate
            }
            Log.debug("Final exhibitions count: \(self.exhibitions.count)")
            self.isLoading = false
        }
    }

    private func calculateReactionCounts(
        for exhibitions: [Exhibition],
        completion: @escaping ([ArtistExhibitionDisplayItem]) -> Void
    ) {
        let group = DispatchGroup()
        var displayItems: [ArtistExhibitionDisplayItem] = []
        let lock = NSLock()  // To protect displayItems from concurrent access

        for exhibition in exhibitions {
            group.enter()
            let artworksInExhibition =
                swiftDataManager.fetchAll(Artwork.self).filter { $0.exhibitionId == exhibition.id }
            let artworkIdsInExhibition = artworksInExhibition.map { $0.id }
            Log.debug("Exhibition \(exhibition.id) has \(artworksInExhibition.count) artworks.")

            if artworkIdsInExhibition.isEmpty {
                lock.lock()
                displayItems.append(
                    ArtistExhibitionDisplayItem(
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
                displayItems.append(
                    ArtistExhibitionDisplayItem(
                        id: exhibition.id, exhibition: exhibition, reactionCount: totalReactionCount
                    ))
                lock.unlock()
                Log.debug(
                    "Calculated \(totalReactionCount) reactions for exhibition \(exhibition.id).")
                group.leave()
            }
        }

        group.notify(queue: .main) {
            Log.debug("finished. Total display items: \(displayItems.count)")
            completion(displayItems)
        }
    }
}
