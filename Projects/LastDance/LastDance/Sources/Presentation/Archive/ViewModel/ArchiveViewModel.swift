//
//  ArchiveViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ArchiveViewModel: ObservableObject {
    @Published var capturedArtworks: [CapturedArtwork] = []
    @Published var currentExhibition: Exhibition?
    @Published var isLoading = false

    private let swiftDataManager = SwiftDataManager.shared
    private let exhibitionId: String
    
    var capturedArtworksCount: Int {
        capturedArtworks.count
    }

    var exhibitionTitle: String {
        currentExhibition?.title ?? "전시 정보 없음"
    }

    var hasArtworks: Bool {
        !capturedArtworks.isEmpty
    }
    
    init(exhibitionId: String) {
        self.exhibitionId = exhibitionId
        loadData()
    }

    func loadData() {
        isLoading = true
        Task {
            do {
                self.currentExhibition = try await fetchCurrentExhibition()
                self.capturedArtworks = try await fetchCapturedArtworksForCurrentExhibition()
            } catch {
                Log.error("Failed to load data: \(error)")
            }
            self.isLoading = false
        }
    }
    
    /// 대각선 효과
    func getRotationAngle(for index: Int) -> Double {
        let angles: [Double] = [-4, 3, 3, -4]  // 좌상, 우상, 좌하, 우하
        return angles[index % angles.count]
    }

    private func fetchCapturedArtworksForCurrentExhibition() async throws -> [CapturedArtwork] {
        guard let container = swiftDataManager.container else {
            throw NSError(
                domain: "ArchiveViewModel",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Container not available"]
            )
        }

        let context = container.mainContext
        let currentExhibitionId = self.exhibitionId
        
        // 현재 전시의 모든 작품 ID 가져오기
        let artworkDescriptor = FetchDescriptor<Artwork>(
            predicate: #Predicate<Artwork> { artwork in
                artwork.exhibitionId == currentExhibitionId
            }
        )
        let artworks = try context.fetch(artworkDescriptor)
        let artworkIds = artworks.map { $0.id }
        
        // 해당 작품들의 CapturedArtwork만 필터링
        let capturedDescriptor = FetchDescriptor<CapturedArtwork>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let allCaptured = try context.fetch(capturedDescriptor)
        
        return allCaptured.filter { captured in
            if let artworkId = captured.artworkId {
                return artworkIds.contains(artworkId)
            }
            return false
        }
    }

    private func fetchCurrentExhibition() async throws -> Exhibition? {
        guard let container = swiftDataManager.container else {
            Log.error("❌ Container not available")
            throw NSError(
                domain: "ArchiveViewModel",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Container not available"]
            )
        }

        let context = container.mainContext
        let currentExhibitionId = self.exhibitionId
        let exhibitionDescriptor = FetchDescriptor<Exhibition>(
            predicate: #Predicate<Exhibition> { exhibition in
                exhibition.id == currentExhibitionId
            }
        )
        
        let exhibition = try context.fetch(exhibitionDescriptor).first

        if exhibition == nil {
            Log.fault("❌ Exhibition not found for id: \(self.exhibitionId)")
        }
        return exhibition
    }
}
