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

        guard
            let artistId = UserDefaults.standard.object(
                forKey: UserDefaultsKey.artistId.rawValue
            ) as? Int
        else {
            Log.error("loadArtistExhibitions - artistId not found in UserDefaults")
            isLoading = false
            return
        }

        Log.debug("🎨 loadArtistExhibitions - artistId: \(artistId)")

        let allExhibitions: [Exhibition] = swiftDataManager.fetchAll(Exhibition.self)
        let allArtworks: [Artwork] = swiftDataManager.fetchAll(Artwork.self)

        Log.debug(
            "🎨 allExhibitions: \(allExhibitions.map { "id=\($0.id)" }.joined(separator: ", "))")
        Log.debug("🎨 allArtworks count: \(allArtworks.count)")
        allArtworks.forEach { art in
            Log.debug(
                "🎨 Artwork id=\(art.id), exId=\(art.exhibitionId), artistId=\(String(describing: art.artistId))"
            )
        }

        let artworksForArtist = allArtworks.filter { $0.artistId == artistId }
        Log.debug("🎨 artworksForArtist(\(artistId)) count: \(artworksForArtist.count)")
        Log.debug("🎨 artworksForArtist exIds: \(Set(artworksForArtist.map { $0.exhibitionId }))")

        let exhibitionIdsForArtist: Set<Int> = Set(
            artworksForArtist.map { $0.exhibitionId }
        )

        let filteredExhibitions = allExhibitions.filter {
            exhibitionIdsForArtist.contains($0.id)
        }

        Log.debug("🎨 filteredExhibitions ids: \(filteredExhibitions.map { $0.id })")

        if filteredExhibitions.isEmpty {
            Log.debug("No exhibitions found for artistId \(artistId)")
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
