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
    
    private let swiftDataManager = SwiftDataManager.shared
    
    init() {
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
    
    var hasReactionItems: Bool {
        !reactionItems.isEmpty
    }
    
    private func loadExhibition() async {
        do {
            guard let container = swiftDataManager.container else {
                throw NSError(domain: "ArtistReactionArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
            }
            
            let context = container.mainContext
            let descriptor = FetchDescriptor<Exhibition>()
            let exhibitions = try context.fetch(descriptor)
            
            await MainActor.run {
                self.exhibition = exhibitions.first
            }
        } catch {
            Log.error("Failed to load exhibition: \(error)")
        }
    }
    
    private func loadReactionItems() async {
        do {
            guard let container = swiftDataManager.container else {
                throw NSError(domain: "ArtistReactionArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
            }
            
            let context = container.mainContext
            let reactionDescriptor = FetchDescriptor<Reaction>()
            let reactions = try context.fetch(reactionDescriptor)
            await MainActor.run {
                if reactions.isEmpty {
                    self.reactionItems = self.generateMockReactionItems()
                } else {
                    self.reactionItems = self.convertReactionsToItems(reactions)
                }
            }
        } catch {
            Log.error("Failed to load reaction items: \(error)")
            await MainActor.run {
                self.reactionItems = self.generateMockReactionItems()
            }
        }
    }
    
    private func generateMockReactionItems() -> [ReactionItem] {
        let categories = ["숨", "빛", "색감", "형태", "감정", "공간"]
        let reactionCounts = [3, 5, 2, 7, 1, 4]
        
        return (0..<6).map { index in
            ReactionItem(
                imageName: "mock_artworkImage_01",
                reactionCount: reactionCounts[index],
                category: categories[index]
            )
        }
    }
    
    private func convertReactionsToItems(_ reactions: [Reaction]) -> [ReactionItem] {
        return reactions.prefix(6).map { reaction in
            ReactionItem(
                imageName: "mock_artworkImage_01", // 추후 실제 이미지 경로로 변경
                reactionCount: 1, // 추후 실제 카운트 로직으로 변경
                category: reaction.category.first ?? "반응"
            )
        }
    }
}
