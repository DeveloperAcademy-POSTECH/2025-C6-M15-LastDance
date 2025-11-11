//
//  ExhibitionArchiveViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ExhibitionArchiveViewModel: ObservableObject {
    @Published var reactions: [Reaction] = []
    @Published var artworks: [Artwork] = []
    @Published var artists: [Artist] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""

    private let swiftDataManager = SwiftDataManager.shared
    private let apiService: ExhibitionAPIServiceProtocol
    private let artworkAPIService = ArtworkAPIService()
    private let visitHistoriesAPIService = VisitHistoriesAPIService()

    let exhibitionId: Int

    init(apiService: ExhibitionAPIServiceProtocol = ExhibitionAPIService(), exhibitionId: Int) {
        self.apiService = apiService
        self.exhibitionId = exhibitionId
        loadData()
    }

    func loadData() {
        Task {
            isLoading = true
            errorMessage = ""

            if await hasLocalData() {
                // 로컬 데이터가 있으면 API 호출 없이 swiftData 로드
                await loadLocalData()
            } else {
                // 로컬 데이터가 없으면 API 호출
                await fetchExhibitionAPI()
            }
        }
    }

    /// SwiftData에 해당 전시의 데이터가 있는지 확인
    private func hasLocalData() async -> Bool {
        do {
            let artworks = try await fetchArtworksForExhibition()
            return !artworks.isEmpty
        } catch {
            return false
        }
    }

    /// 로컬 데이터만 로드 (API 호출 X)
    private func loadLocalData() async {
        do {
            reactions = try await fetchReactions()
            artists = try await fetchArtists()
            artworks = try await fetchArtworksForExhibition()

            Log.debug(
                "로컬 데이터 로드 완료 - Reactions: \(reactions.count), Artworks: \(artworks.count), Artists: \(artists.count)"
            )
            isLoading = false
        } catch {
            Log.error("로컬 데이터 로드 실패: \(error)")
            isLoading = false
            errorMessage = "데이터를 불러오는데 실패했습니다."
        }
    }

    /// API호출
    private func fetchExhibitionAPI() async {
        apiService.getDetailExhibition(exhibitionId: exhibitionId) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    Log.debug("전시 상세 조회 API 성공")

                    Task {
                        do {
                            self.reactions = try await self.fetchReactions()
                            self.artists = try await self.fetchArtists()
                            self.artworks = try await self.fetchArtworksForExhibition()

                            Log.debug(
                                "로컬 데이터 로드 완료 - Reactions: \(self.reactions.count), Artworks: \(self.artworks.count), Artists: \(self.artists.count)"
                            )
                        } catch {
                            Log.error("로컬 데이터 로드 실패: \(error)")
                        }
                    }

                case let .failure(error):
                    self.errorMessage = "전시 정보를 불러오는데 실패했습니다."
                    Log.error("전시 상세 조회 실패: \(error)")
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
        let artworkDescriptor = FetchDescriptor<Artwork>(
            predicate: #Predicate<Artwork> { artwork in
                artwork.exhibitionId == exhibitionId
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
        let descriptor = FetchDescriptor<Artwork>(
            predicate: #Predicate<Artwork> { artwork in
                artwork.exhibitionId == exhibitionId
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

    /// 작품 상세 조회 API 함수
    func fetchArtworkDetail(artworkId: Int) {
        Log.debug("작품 상세 조회 API 호출 - artworkId: \(artworkId)")

        artworkAPIService.getArtworkDetail(artworkId: artworkId) { result in
            Task {
                switch result {
                case let .success(artwork):
                    Log.debug("작품 상세 조회 성공! 작품명: \(artwork.title)")
                    // 로컬 데이터 다시 로드
                    self.loadData()
                case let .failure(error):
                    Log.error("작품 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
