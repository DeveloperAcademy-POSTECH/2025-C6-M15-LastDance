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
  @Published var artworks: [ArtworkDisplayItem] = []  // Changed type
  @Published var isLoading = false

  private let exhibitionId: Int
  private let swiftDataManager = SwiftDataManager.shared

  var exhibitionTitle: String {
    exhibition?.title ?? "전시 제목"
  }

  private var exhibition: Exhibition?
  private let reactionAPIService: ReactionAPIServiceProtocol
  private let artworkAPIService: ArtworkAPIServiceProtocol  // Added dependency

  init(
    exhibitionId: Int,
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

    let exhibitionDescriptor = FetchDescriptor<Exhibition>(
      predicate: #Predicate { $0.id == exhibitionId }
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

    artworkAPIService.getArtworks(artistId: nil, exhibitionId: exhibitionId) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let artworkDtos):
        Log.debug("Fetched \(artworkDtos.count) artworks for exhibition \(exhibitionId).")

        if artworkDtos.isEmpty {
          Log.warning("No artworks \(exhibitionId).")
          self.isLoading = false
          return
        }

        let group = DispatchGroup()
        var fetchedArtworkDisplayItems: [ArtworkDisplayItem] = []
        let lock = NSLock()

        for artworkDto in artworkDtos {
          group.enter()
          let artworkModel = ArtworkMapper.mapDtoToModel(artworkDto, exhibitionId: exhibitionId)
          self.swiftDataManager.upsertArtwork(artworkModel)
          self.reactionAPIService.getReactions(
            artworkId: artworkDto.id, visitorId: nil, visitId: nil
          ) { reactionResult in
            var reactionCount = 0
            switch reactionResult {
            case .success(let reactions):
              reactionCount = reactions.count
              Log.debug("Artwork \(artworkDto.id) has \(reactionCount) reactions.")
            case .failure(let error):
              Log.error(
                "Failed to fetch reactions for artwork \(artworkDto.id): \(error.localizedDescription)"
              )
            }

            lock.lock()
            fetchedArtworkDisplayItems.append(
              ArtworkDisplayItem(
                id: artworkDto.id, artwork: artworkModel, reactionCount: reactionCount))
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
        Log.error(
          "Failed to fetch artworks for exhibition \(exhibitionId): \(error.localizedDescription)")
        self.isLoading = false
      }
    }
  }
}
