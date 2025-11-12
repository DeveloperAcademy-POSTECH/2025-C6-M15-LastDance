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

    // MARK: - Image Size Constants

    private enum ImageSize {
        static let minWidth: CGFloat = 300
        static let maxWidth: CGFloat = 345
        static let minHeight: CGFloat = 400
        static let maxHeight: CGFloat = 468
        static let animationThreshold: CGFloat = 100
        static let tabBarFixThreshold: CGFloat = 492
    }

    // MARK: - Initialization

    init(artworkId: Int) {
        self.artworkId = artworkId
    }

    // MARK: - Computed Properties

    func imageWidth(for scrollOffset: CGFloat) -> CGFloat {
        guard scrollOffset < ImageSize.animationThreshold else {
            return ImageSize.minWidth
        }
        let progress = scrollOffset / ImageSize.animationThreshold
        return ImageSize.maxWidth - (progress * (ImageSize.maxWidth - ImageSize.minWidth))
    }

    func imageHeight(for scrollOffset: CGFloat) -> CGFloat {
        guard scrollOffset < ImageSize.animationThreshold else {
            return ImageSize.minHeight
        }
        let progress = scrollOffset / ImageSize.animationThreshold
        return ImageSize.maxHeight - (progress * (ImageSize.maxHeight - ImageSize.minHeight))
    }

    func isTabBarFixed(for scrollOffset: CGFloat) -> Bool {
        return scrollOffset > ImageSize.tabBarFixThreshold
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
