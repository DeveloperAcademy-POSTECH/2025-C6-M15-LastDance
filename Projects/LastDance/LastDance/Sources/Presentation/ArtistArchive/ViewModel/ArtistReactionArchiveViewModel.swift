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
    @Published var artworks: [ArtworkDisplayItem] = [] // Changed type
    @Published var isLoading = false
    
    var exhibitionTitle: String {
        exhibition?.title ?? "전시 제목"
    }
    private var exhibition: Exhibition?
    private let exhibitionId: String
    private let swiftDataManager = SwiftDataManager.shared
    private let reactionAPIService: ReactionAPIServiceProtocol
    private let artworkAPIService: ArtworkAPIServiceProtocol // Added dependency

    init(
        exhibitionId: String,
        reactionAPIService: ReactionAPIServiceProtocol = ReactionAPIService(),
        artworkAPIService: ArtworkAPIServiceProtocol = ArtworkAPIService()
    ) {
        self.exhibitionId = exhibitionId
        self.reactionAPIService = reactionAPIService
        self.artworkAPIService = artworkAPIService
    }
    
    func loadArtworksAndReactions() {
        isLoading = true
        artworks = []
        
        guard let intExhibitionId = Int(exhibitionId) else {
            Log.error("Invalid exhibition ID: \(exhibitionId)")
            isLoading = false
            return
        }
        
        let exhibitionDescriptor = FetchDescriptor<Exhibition>(
            predicate: #Predicate { $0.id == intExhibitionId }
        )
        do {
            exhibition = try swiftDataManager.container?.mainContext.fetch(exhibitionDescriptor).first
        } catch {
            Log.error("Failed SwiftData: \(error.localizedDescription)")
        }
        
        guard let currentExhibition = exhibition else {
            Log.warning("Exhibition not found for id: \(exhibitionId)")
            isLoading = false
            return
        }
        
        artworkAPIService.getArtworks(artistId: nil, exhibitionId: intExhibitionId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let artworkDtos):
                Log.debug("Fetched \(artworkDtos.count) artworks for exhibition \(intExhibitionId).")

                if artworkDtos.isEmpty {
                    Log.warning("No artworks \(intExhibitionId).")
                    self.isLoading = false
                    return
                }

                let group = DispatchGroup()
                var fetchedArtworkDisplayItems: [ArtworkDisplayItem] = []
                let lock = NSLock()

                for artworkDto in artworkDtos {
                    group.enter()
                    let artworkModel = ArtworkMapper.mapDtoToModel(artworkDto, exhibitionId: intExhibitionId)
                    self.swiftDataManager.upsertArtwork(artworkModel)
                    self.reactionAPIService.getReactions(artworkId: artworkDto.id, visitorId: nil, visitId: nil) { reactionResult in
                        var reactionCount = 0
                        switch reactionResult {
                        case .success(let reactions):
                            reactionCount = reactions.count
                            Log.debug("Artwork \(artworkDto.id) has \(reactionCount) reactions.")
                        case .failure(let error):
                            Log.error("Failed to fetch reactions for artwork \(artworkDto.id): \(error.localizedDescription)")
                        }
                        
                        lock.lock()
                        fetchedArtworkDisplayItems.append(ArtworkDisplayItem(id: artworkDto.id, artwork: artworkModel, reactionCount: reactionCount))
                        lock.unlock()
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.artworks = fetchedArtworkDisplayItems.sorted {
                        $0.artwork.title < $1.artwork.title
                    }
                    Log.debug("Final artworks count: \(self.artworks.count)")
                    self.isLoading = false
                }

            case .failure(let error):
                Log.error("Failed to fetch artworks for exhibition \(intExhibitionId): \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
}
