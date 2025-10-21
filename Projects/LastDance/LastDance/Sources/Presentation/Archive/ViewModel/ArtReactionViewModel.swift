//
//  ArtReactionViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/21/25.
//

import SwiftUI
import SwiftData

@MainActor
final class ArtReactionViewModel: ObservableObject {
    @Published var reactions: [Reaction] = []
    @Published var isLoading = false
    
    private let artworkId: Int
    private let swiftDataManager = SwiftDataManager.shared
    
    init(artworkId: Int) {
        self.artworkId = artworkId
    }
    
    func loadReactions() {
        isLoading = true
        
        guard let container = swiftDataManager.container else {
            Log.error("Container not available")
            isLoading = false
            return
        }
        
        let context = container.mainContext
        
        do {
            let targetId = self.artworkId
            let predicate = #Predicate<Reaction> { reaction in
                reaction.artworkId == targetId
            }
            let descriptor = FetchDescriptor<Reaction>(predicate: predicate)
            reactions = try context.fetch(descriptor)
            
            Log.debug("Loaded \(reactions.count) reactions for artwork \(artworkId)")
        } catch {
            Log.error("Failed to load reactions: \(error)")
        }
        
        isLoading = false
    }
}
