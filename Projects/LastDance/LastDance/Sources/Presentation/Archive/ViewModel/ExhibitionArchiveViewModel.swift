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
    @Published var errorMessage: String = ""

    private let swiftDataManager = SwiftDataManager.shared
    private let apiService: ExhibitionAPIServiceProtocol
    let exhibitionId: Int

    init(apiService: ExhibitionAPIServiceProtocol = ExhibitionAPIService(), exhibitionId: Int) {
        self.apiService = apiService
        self.exhibitionId = exhibitionId
    }
    
    func loadData() {
        isLoading = true
        errorMessage = ""

        // API에서 전시 상세 조회
        apiService.getDetailExhibition(exhibitionId: exhibitionId) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success:
                    Log.debug("[ExhibitionArchiveViewModel] 전시 상세 조회 API 성공")

                    // API 응답 후 로컬 데이터 로드
                    Task { @MainActor in
                        do {
                            // SwiftData에 저장된 Exhibition Model 확인
                            if let exhibition = self.swiftDataManager.fetchById(Exhibition.self, id: String(self.exhibitionId)) {
                                Log.debug("[ExhibitionArchiveViewModel] Exhibition Model 로드 완료: \(exhibition.title)")
                            } else {
                                Log.error("[ExhibitionArchiveViewModel] Exhibition Model을 찾을 수 없습니다. id: \(self.exhibitionId)")
                            }

                            // 최신 로컬 데이터 가져오기
                            self.reactions = try await self.fetchReactions()
                            self.artworks  = try await self.fetchArtworks()
                            self.artists   = try await self.fetchArtists()

                            Log.debug("[ExhibitionArchiveViewModel] 로컬 데이터 로드 완료 - Reactions: \(self.reactions.count), Artworks: \(self.artworks.count), Artists: \(self.artists.count)")
                        } catch {
                            Log.error("[ExhibitionArchiveViewModel] 로컬 데이터 로드 실패: \(error)")
                        }
                    }

                case .failure(let error):
                    self.errorMessage = "전시 정보를 불러오는데 실패했습니다."
                    Log.error("[ExhibitionArchiveViewModel] 전시 상세 조회 실패: \(error)")
                }
            }
        }
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

