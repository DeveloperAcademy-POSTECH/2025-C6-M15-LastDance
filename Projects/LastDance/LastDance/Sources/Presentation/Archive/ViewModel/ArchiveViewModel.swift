//
//  ArchiveViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI
import SwiftData

@MainActor
final class ArchiveViewModel: ObservableObject {
    @Published var capturedArtworks: [CapturedArtwork] = []
    @Published var currentExhibition: Exhibition?
    @Published var isLoading = false
    
    private let swiftDataManager = SwiftDataManager.shared
    
    init() {
        loadCapturedArtworks()
        loadCurrentExhibition()
    }
    
    // MARK: - Public Methods
    
    func loadCapturedArtworks() {
        isLoading = true
        
        Task {
            do {
                let artworks = try await fetchCapturedArtworks()
                await MainActor.run {
                    self.capturedArtworks = artworks
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                Log.error("Failed to load captured artworks: \(error)")
            }
        }
    }
    
    func loadCurrentExhibition() {
        Task {
            do {
                let exhibition = try await fetchCurrentExhibition()
                await MainActor.run {
                    self.currentExhibition = exhibition
                }
            } catch {
                Log.error("Failed to load current exhibition: \(error)")
            }
        }
    }
    
    
    var capturedArtworksCount: Int {
        capturedArtworks.count
    }
    
    var exhibitionTitle: String {
        currentExhibition?.title ?? "전시 정보 없음"
    }
    
    var hasArtworks: Bool {
        !capturedArtworks.isEmpty
    }
    

    
    private func fetchCapturedArtworks() async throws -> [CapturedArtwork] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<CapturedArtwork>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    private func fetchCurrentExhibition() async throws -> Exhibition? {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Exhibition>()
        let exhibitions = try context.fetch(descriptor)
        return exhibitions.first
    }
}
