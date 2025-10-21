//
//  ArtistReactionArchiveViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/15/25.
//

import SwiftUI
import SwiftData

@MainActor
final class ArtistReactionArchiveViewModel: ObservableObject {
    @Published var exhibition: Exhibition?
    @Published var reactionItems: [ReactionItem] = []
    @Published var isLoading = false

    private let exhibitionId: Int
    private let swiftDataManager = SwiftDataManager.shared

    init(exhibitionId: Int) {
        self.exhibitionId = exhibitionId
        loadData()
    }

    func loadData() {
        isLoading = true
        Task {
            await loadExhibitionAndReactions()
            self.isLoading = false
        }
    }

    var exhibitionTitle: String {
        exhibition?.title ?? "전시 제목"
    }

    private func loadExhibitionAndReactions() async {
        do {
            guard let container = swiftDataManager.container else {
                throw NSError(domain: "ArtistReactionArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
            }

            let context = container.mainContext

            // Exhibition 데이터 가져오기
            let targetId = self.exhibitionId
            let predicate = #Predicate<Exhibition> { exhibition in
                exhibition.id == targetId
            }
            let exhibitionDescriptor = FetchDescriptor<Exhibition>(predicate: predicate)
            let exhibitions = try context.fetch(exhibitionDescriptor)

            guard let fetchedExhibition = exhibitions.first else {
                Log.warning("Exhibition not found for id: \(exhibitionId)")
                return
            }

            // Reaction 데이터 가져오기
            let exhibitionArtworks = fetchedExhibition.artworks
            let reactionDescriptor = FetchDescriptor<Reaction>()
            let allReactions = try context.fetch(reactionDescriptor)

            let items: [ReactionItem] = exhibitionArtworks.compactMap { artwork -> ReactionItem? in
                let artworkReactions = allReactions.filter { $0.artworkId == artwork.id }
                guard !artworkReactions.isEmpty else { return nil }
                return ReactionItem(
                    imageName: artwork.thumbnailURL ?? "mock_artworkImage_01",
                    reactionCount: artworkReactions.count,
                    artworkTitle: artwork.title
                )
            }

            await MainActor.run {
                self.exhibition = fetchedExhibition
                self.reactionItems = items
            }
        } catch {
            Log.error("Failed to load exhibition and reactions: \(error)")
        }
    }
}
