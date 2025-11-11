//
//  ClipReactionInputViewModel.swift
//  LastDance
//
//  Created by 배현진 on 11/10/25.
//

import SwiftUI

@MainActor
final class ClipArtReactionViewModel: ObservableObject {
    @Published var artwork: Artwork?
    @Published var artist: Artist?
    @Published var message: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoaded: Bool = false

    let limit = 500

    private let artworkId: Int
    private let artworkService: ClipArtworkAPIServiceProtocol

    init(artworkId: Int, artworkService: ClipArtworkAPIServiceProtocol = ClipArtworkAPIService()) {
        self.artworkId = artworkId
        self.artworkService = artworkService
    }

    var artistName: String? {
        artist?.name
    }
    
    var hasText: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func loadArtwork() async {
        isLoading = true
        do {
            // 작품 상세 가져오기
            let fetchedArtwork = try await artworkService.loadArtworkDetail(id: 25)
            self.artwork = fetchedArtwork

            // 작가 정보도 있으면 가져오기
            if let artistId = fetchedArtwork.artistId {
                let fetchedArtist = try await artworkService.loadArtistDetail(id: artistId)
                self.artist = fetchedArtist
            }
            
            self.isLoaded = true
        } catch {
            Log.error("loadArtwork failed: \(error)")
            self.isLoaded = true
        }
        isLoading = false
    }

    func updateMessage(_ newValue: String) {
        if newValue.count > limit {
            message = String(newValue.prefix(limit))
        } else {
            message = newValue
        }
    }

    func isTabBarFixed(for scrollOffset: CGFloat) -> Bool {
        scrollOffset > 492
    }
}
