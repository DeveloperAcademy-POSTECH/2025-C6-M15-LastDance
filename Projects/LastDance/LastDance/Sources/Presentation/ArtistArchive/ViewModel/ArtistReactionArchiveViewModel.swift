//
//  ArtistReactionArchiveViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/15/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ArtistReactionArchiveViewModel: ObservableObject {
    @Published var reactionItems: [ReactionItem] = []
    @Published var isLoading = false
    
    var exhibitionTitle: String {
        exhibition?.title ?? "전시 제목"
    }
    private var exhibition: Exhibition?
    private let exhibitionId: String
    private let swiftDataManager = SwiftDataManager.shared
    private let reactionAPIService: ReactionAPIServiceProtocol // Add reactionAPIService

    init(
        exhibitionId: String,
        reactionAPIService: ReactionAPIServiceProtocol = ReactionAPIService()
    ) {
        self.exhibitionId = exhibitionId
        self.reactionAPIService = reactionAPIService
    }
    
    func loadReactionsFromDB() {
        isLoading = true
        
        guard let container = swiftDataManager.container else {
            isLoading = false
            return
        }
        let context = container.mainContext
        
        do {
            guard let intExhibitionId = Int(exhibitionId) else {
                Log.error("Invalid exhibition ID: \(exhibitionId)")
                isLoading = false
                return
            }

            let exhibitionDescriptor = FetchDescriptor<Exhibition>(
                predicate: #Predicate { $0.id == intExhibitionId }
            )
            exhibition = try context.fetch(exhibitionDescriptor).first
            
            guard let currentExhibition = exhibition else {
                Log.warning("Exhibition not found for id: \(exhibitionId)")
                isLoading = false
                return
            }

            let artworksInExhibition =
            swiftDataManager.fetchAll(Artwork.self).filter { $0.exhibitionId == currentExhibition.id }
            
            let group = DispatchGroup()
            var fetchedReactionItems: [ReactionItem] = []

            for artwork in artworksInExhibition {
                group.enter()
                reactionAPIService.getReactions(
                    artworkId: artwork.id,
                    visitorId: nil,
                    visitId: nil
                ) { [weak self] result in
                    guard let self = self else { group.leave(); return }
                    
                    switch result {
                    case .success(let reactions):
                        if !reactions.isEmpty {
                            let reactionCount = reactions.count
                            let item = ReactionItem(
                                imageName: artwork.thumbnailURL ?? "mock_artworkImage_01",
                                reactionCount: reactionCount,
                                artworkTitle: artwork.title
                            )
                            fetchedReactionItems.append(item)
                        }
                    case .failure(let error):
                        Log.error("Failed. artwork \(artwork.id): \(error.localizedDescription)")
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.reactionItems = fetchedReactionItems
                self.isLoading = false
            }

        } catch {
            Log.error("Failed to load reactions: \(error)")
            isLoading = false
        }
    }
}
