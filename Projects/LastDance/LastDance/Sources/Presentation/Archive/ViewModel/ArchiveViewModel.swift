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
    private var exhibitionId: String?

    var capturedArtworksCount: Int {
        capturedArtworks.count
    }

    var exhibitionTitle: String {
        currentExhibition?.title ?? "전시 정보 없음"
    }

    var hasArtworks: Bool {
        !capturedArtworks.isEmpty
    }

    init(exhibitionId: String? = nil) {
        self.exhibitionId = exhibitionId
        if exhibitionId != nil {
            loadData()
        }
    }
    
    func loadData() {
        isLoading = true
        Task {
            do {
                // exhibitionId가 있으면 해당 전시 정보 먼저 로드
                if let exhibitionId = exhibitionId {
                    self.currentExhibition = try await fetchExhibition(by: exhibitionId)
                    self.capturedArtworks = try await fetchCapturedArtworks(for: exhibitionId)
                } else {
                    // 먼저 캡처된 작품들 로드
                    self.capturedArtworks = try await fetchCapturedArtworks(for: nil)

                    // 캡처된 작품들을 기반으로 전시 정보 로드
                    self.currentExhibition = try await fetchCurrentExhibition()
                }
            } catch {
                Log.error("Failed to load data: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func loadCapturedArtworks() {
        isLoading = true
        Task {
            do {
                self.capturedArtworks = try await fetchCapturedArtworks(for: exhibitionId)
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
    
    /// 대각선 효과
    func getRotationAngle(for index: Int) -> Double {
        let angles: [Double] = [-4, 3, 3, -4] // 좌상, 우상, 좌하, 우하
        return angles[index % angles.count]
    }
    
    private func fetchCapturedArtworks(for exhibitionId: String?) async throws -> [CapturedArtwork] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }

        let context = container.mainContext

        // exhibitionId가 있으면 해당 전시의 작품만 필터링
        if let exhibitionId = exhibitionId {
            // 1. 해당 전시의 모든 artwork ID 가져오기
            let artworkDescriptor = FetchDescriptor<Artwork>(
                predicate: #Predicate<Artwork> { artwork in
                    artwork.exhibitionId == exhibitionId
                }
            )
            let artworks = try context.fetch(artworkDescriptor)
            let artworkIds = artworks.map { $0.id }

            // 2. 해당 artwork ID들에 해당하는 CapturedArtwork만 가져오기
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
        } else {
            // exhibitionId가 없으면 모든 캡처된 작품 반환
            let descriptor = FetchDescriptor<CapturedArtwork>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            return try context.fetch(descriptor)
        }
    }

    private func fetchExhibition(by id: String) async throws -> Exhibition? {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }

        let context = container.mainContext
        let descriptor = FetchDescriptor<Exhibition>(
            predicate: #Predicate<Exhibition> { exhibition in
                exhibition.id == id
            }
        )
        return try context.fetch(descriptor).first
    }
    
    private func fetchCurrentExhibition() async throws -> Exhibition? {
        guard let container = swiftDataManager.container else {
            Log.error("❌ Container not available")
            throw NSError(domain: "ArchiveViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }

        let context = container.mainContext

        // 캡처된 작품들 먼저 가져오기
        let capturedArtworks = try await fetchCapturedArtworks(for: nil)

        // 캡처된 작품이 없으면 nil 반환
        guard let firstCaptured = capturedArtworks.first,
              let artworkId = firstCaptured.artworkId else {
            return nil
        }

        let artworkDescriptor = FetchDescriptor<Artwork>(
            predicate: #Predicate<Artwork> { artwork in
                artwork.id == artworkId
            }
        )
        guard let artwork = try context.fetch(artworkDescriptor).first else {
            Log.error("❌ Artwork not found for id: \(artworkId)")
            return nil
        }

        let exhibitionId = artwork.exhibitionId
        let exhibitionDescriptor = FetchDescriptor<Exhibition>(
            predicate: #Predicate<Exhibition> { exhibition in
                exhibition.id == exhibitionId
            }
        )
        let exhibition = try context.fetch(exhibitionDescriptor).first

        if exhibition == nil {
            Log.error("❌ Exhibition not found for id: \(exhibitionId)")
        }

        return exhibition
    }
}
