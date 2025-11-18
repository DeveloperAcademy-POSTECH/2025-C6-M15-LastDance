//
//  ArtReactionViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/21/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ArtReactionViewModel: ObservableObject {
    // MARK: - Properties

    @Published var reactions: [Reaction] = []
    @Published var isLoading = false

    private let artworkId: Int
    private let swiftDataManager = SwiftDataManager.shared

    // MARK: - Initialization

    init(artworkId: Int) {
        self.artworkId = artworkId
    }

    // MARK: - Public Methods

    func loadReactions() {
        isLoading = true

        guard let container = swiftDataManager.container else {
            isLoading = false
            return
        }

        let context = container.mainContext

        do {
            let targetId = artworkId
            let predicate = #Predicate<Reaction> { reaction in
                reaction.artworkId == targetId
            }
            let descriptor = FetchDescriptor<Reaction>(predicate: predicate)
            reactions = try context.fetch(descriptor)
        } catch {
            Log.error("Failed to load reactions: \(error)")
        }
        isLoading = false
    }
}
