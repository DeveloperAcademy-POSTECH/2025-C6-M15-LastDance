//
//  ExhibitionArchiveViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftUI
import SwiftData

@MainActor
final class ExhibitionArchiveViewModel: ObservableObject {
    @Published var reactions: [Reaction] = []
    @Published var artworks: [Artwork] = []
    @Published var artists: [Artist] = []
    @Published var isLoading = false
    
    private let swiftDataManager = SwiftDataManager.shared
    let exhibition: Exhibition
    
    init(exhibition: Exhibition) {
        self.exhibition = exhibition
        loadData()
    }
    
    func loadData() {
        isLoading = true
        Task { @MainActor in
            defer { self.isLoading = false }
            do {
                self.reactions = try await fetchReactions()
                self.artworks  = try await fetchArtworks()
                self.artists   = try await fetchArtists()
            } catch {
            }
        }
    }
    
    var exhibitionTitle: String {
        exhibition.title
    }
    
    var exhibitionDateString: String {
        return exhibition.startDate.toShortDateString()
    }
    
    var hasReactions: Bool {
        !reactions.isEmpty
    }
    
    func artwork(for reaction: Reaction) -> Artwork? {
        artworks.first { $0.id == reaction.artworkId }
    }
    
    func artist(for artwork: Artwork) -> Artist? {
        guard let artistId = artwork.artistId else { return nil }
        return artists.first { $0.id == artistId }
    }
    
    private func fetchReactions() async throws -> [Reaction] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ExhibitionArchiveViewModel", code: 1)
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Reaction>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    private func fetchArtworks() async throws -> [Artwork] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ExhibitionArchiveViewModel", code: 1)
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Artwork>()
        
        return try context.fetch(descriptor)
    }
    
    private func fetchArtists() async throws -> [Artist] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ExhibitionArchiveViewModel", code: 1)
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Artist>()
        
        return try context.fetch(descriptor)
    }
}

