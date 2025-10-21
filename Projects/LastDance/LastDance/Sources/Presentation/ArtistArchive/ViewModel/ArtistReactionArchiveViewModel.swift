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
            do {
                await loadExhibition()
                await loadReactionItems()
            } catch {
                Log.error("Failed to load artist reaction archive data: \(error)")
            }
            self.isLoading = false
        }
    }

    var exhibitionTitle: String {
        exhibition?.title ?? "전시 제목"
    }
    private var exhibition: Exhibition?
    private let exhibitionId: String
    private let swiftDataManager = SwiftDataManager.shared
    
    init(exhibitionId: String) {
        self.exhibitionId = exhibitionId
    }
    
    private func loadExhibition() async {
        do {
            guard let container = swiftDataManager.container else {
                throw NSError(domain: "ArtistReactionArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
            }
            
            let context = container.mainContext
            let targetId = self.exhibitionId
            let predicate = #Predicate<Exhibition> { exhibition in
                exhibition.id == targetId
            }
            let descriptor = FetchDescriptor<Exhibition>(predicate: predicate)
            let exhibitions = try context.fetch(descriptor)
            
            await MainActor.run {
                self.exhibition = exhibitions.first
            }
        } catch {
            Log.error("Failed to load exhibition: \(error)")
        }
        let context = container.mainContext
        do {
            //Exhibition 데이터 가져오기
            let exhibitionDescriptor = FetchDescriptor<Exhibition>()
            let exhibitions = try context.fetch(exhibitionDescriptor)
            exhibition = exhibitions.first(where: { String($0.id) == exhibitionId })
            
            guard let exhibition = exhibition else {
                Log.warning("Exhibition not found for id: \(exhibitionId)")
                isLoading = false
                return
            }
            let exhibitionArtworks = exhibition.artworks
            let reactionDescriptor = FetchDescriptor<Reaction>()
            let allReactions = try context.fetch(reactionDescriptor)
            
            reactionItems = exhibitionArtworks.compactMap { artwork in
                let artworkReactions = allReactions.filter { $0.artworkId == artwork.id }
                guard !artworkReactions.isEmpty else { return nil }
                return ReactionItem(
                    imageName: artwork.thumbnailURL ?? "mock_artworkImage_01",
                    reactionCount: artworkReactions.count,
                    artworkTitle: artwork.title
                )
            }
        } catch {
            Log.error("Failed to load reactions: \(error)")
        }
        isLoading = false
    }
}
