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
    
    /// 전시 상세 조회 api 호출
    func loadData() {
        isLoading = true
        errorMessage = ""

        apiService.getDetailExhibition(exhibitionId: exhibitionId) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    Log.debug("[ExhibitionArchiveViewModel] 전시 상세 조회 API 성공")

                    Task { @MainActor in
                        do {
                            self.reactions = try await self.fetchReactions()
                            self.artists   = try await self.fetchArtists()
                            self.artworks = try await self.fetchArtworksForExhibition()

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

    /// 반응을 남긴 작품들만 필터링
    func getReactedArtworks() -> [Artwork] {
        let reactionArtworkIds = Set(reactions.map { $0.artworkId })
        return artworks.filter { reactionArtworkIds.contains($0.id) }
    }

    /// 반응을 남긴 작품이 있는지 확인하는 함수
    func hasReactedArtworks() -> Bool {
        !getReactedArtworks().isEmpty
    }

    /// 작품 ID로 작가 정보를 찾아주는 함수
    func artist(for artwork: Artwork) -> Artist? {
        guard let artistId = artwork.artistId else { return nil }
        return artists.first { $0.id == artistId }
    }
    
    /// 해당 전시의 반응만 조회
    private func fetchReactions() async throws -> [Reaction] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ExhibitionArchiveViewModel", code: 1)
        }

        let context = container.mainContext

        // 해당 전시의 작품 ID 조회
        let exhibitionIdString = String(exhibitionId)
        let artworkDescriptor = FetchDescriptor<Artwork>(
            predicate: #Predicate<Artwork> { artwork in
                artwork.exhibitionId == exhibitionIdString
            }
        )
        let exhibitionArtworks = try context.fetch(artworkDescriptor)
        let artworkIds = Set(exhibitionArtworks.map { $0.id })

        // 모든 반응 조회 후 해당 전시 작품의 반응만 필터링
        let reactionDescriptor = FetchDescriptor<Reaction>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let allReactions = try context.fetch(reactionDescriptor)

        return allReactions.filter { artworkIds.contains($0.artworkId) }
    }
    
    /// 해당 전시의 작품만 조회
    private func fetchArtworksForExhibition() async throws -> [Artwork] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ExhibitionArchiveViewModel", code: 1)
        }

        let context = container.mainContext
        let exhibitionIdString = String(exhibitionId)
        let descriptor = FetchDescriptor<Artwork>(
            predicate: #Predicate<Artwork> { artwork in
                artwork.exhibitionId == exhibitionIdString
            }
        )
        return try context.fetch(descriptor)
    }
    
    /// 작가 정보 가져오기 (artist 함수에서 못가져 올 경우를 대비)
    private func fetchArtists() async throws -> [Artist] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ExhibitionArchiveViewModel", code: 1)
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Artist>()
        
        return try context.fetch(descriptor)
    }
}

