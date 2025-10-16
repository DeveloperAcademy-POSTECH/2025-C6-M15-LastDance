//
//  ArtistReactionViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/15/25.
//

import SwiftUI
import SwiftData

@MainActor
final class ArtistReactionViewModel: ObservableObject {
    @Published var exhibition: Exhibition?
    @Published var totalReactionCount: Int = 0
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
                await loadTotalReactionCount()
            } catch {
                Log.error("Failed to load artist reaction data: \(error)")
            }
            self.isLoading = false
        }
    }
    
    var exhibitionTitle: String {
        exhibition?.title ?? "전시 제목"
    }
    
    var artworkImageName: String {
        "mock_artworkImage_01"
    }
    
    private func loadExhibition() async {
        do {
            guard let container = swiftDataManager.container else {
                throw NSError(domain: "ArtistReactionViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
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
    
    private func loadTotalReactionCount() async {
        do {
            guard let container = swiftDataManager.container else {
                throw NSError(domain: "ArtistReactionViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
            }
            
            let context = container.mainContext
            let descriptor = FetchDescriptor<Reaction>()
            let reactions = try context.fetch(descriptor)
            
            await MainActor.run {
                self.totalReactionCount = reactions.count
            }
        } catch {
            Log.error("Failed to load reaction count: \(error)")
            await MainActor.run {
                self.totalReactionCount = 0
            }
        }
    }
}
