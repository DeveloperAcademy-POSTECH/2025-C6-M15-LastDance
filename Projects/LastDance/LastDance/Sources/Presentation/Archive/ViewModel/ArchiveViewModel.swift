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
    
    func loadCapturedArtworks() {
        isLoading = true
        Task {
            do {
                self.capturedArtworks = try await fetchCapturedArtworks()
            } catch {
                Log.error("Failed to load captured artworks: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func loadCurrentExhibition() {
        Task {
            do {
                self.currentExhibition = try await fetchCurrentExhibition()
            } catch {
                Log.error("❌ Failed to load current exhibition: \(error)")
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
            Log.error("❌ Container not available")
            throw NSError(domain: "ArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Exhibition>()
        let exhibitions = try context.fetch(descriptor)
        return exhibitions.first
    }
    /// 대각선 효과
    func getRotationAngle(for index: Int) -> Double {
        let angles: [Double] = [-4, 3, 3, -4] // 좌상, 우상, 좌하, 우하
        return angles[index % angles.count]
    }
}
