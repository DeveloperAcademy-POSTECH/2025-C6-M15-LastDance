//
//  ArtistReactionViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/15/25.
//

import SwiftUI
import SwiftData

struct MockExhibitionData: Identifiable {
    let id: String
    let title: String
    let coverImageName: String
    let reactionCount: Int
}

@MainActor
final class ArtistReactionViewModel: ObservableObject {
    @Published var exhibitions: [MockExhibitionData] = []
    @Published var isLoading = false
    
    private let swiftDataManager = SwiftDataManager.shared
    
    func loadExhibitionsFromDB() {
        isLoading = true
        
        guard let container = swiftDataManager.container else {
            Log.error("Container not available")
            isLoading = false
            return
        }
        
        let context = container.mainContext
        
        do {
            // SwiftData에서 Exhibition과 Reaction 데이터
            let exhibitionDescriptor = FetchDescriptor<Exhibition>()
            let dbExhibitions = try context.fetch(exhibitionDescriptor)
            let reactionDescriptor = FetchDescriptor<Reaction>()
            let allReactions = try context.fetch(reactionDescriptor)
            
            // Exhibition별 반응 수 계산
            exhibitions = dbExhibitions.map { exhibition in
                let reactionCount = allReactions.filter { reaction in
                    exhibition.artworks.contains(where: { $0.id == reaction.artworkId })
                }.count
                
                return MockExhibitionData(
                    id: String(exhibition.id),
                    title: exhibition.title,
                    coverImageName: exhibition.coverImageName ?? "mock_exhibitionCoverImage",
                    reactionCount: reactionCount > 0 ? reactionCount : Int.random(in: 20...100)
                )
            }
        } catch {
            Log.error("Failed to load exhibitions: \(error)")
        }
        
        isLoading = false
    }
}
