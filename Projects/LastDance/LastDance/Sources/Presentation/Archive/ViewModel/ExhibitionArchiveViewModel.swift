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

    let exhibitionId: Int

    private let swiftDataManager = SwiftDataManager.shared
    private let exhibitionService: ExhibitionAPIServiceProtocol
    private let artworkService: ArtworkAPIServiceProtocol

    init(
        exhibitionId: Int,
        exhibitionService: ExhibitionAPIServiceProtocol = ExhibitionAPIService(),
        artworkService: ArtworkAPIServiceProtocol = ArtworkAPIService()
    ) {
        self.exhibitionId = exhibitionId
        self.exhibitionService = exhibitionService
        self.artworkService = artworkService

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

            isLoading = false
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
        } catch {
            Log.error("로컬 데이터 로드 실패: \(error)")
            errorMessage = "데이터를 불러오는데 실패했습니다."
        }
    }

    /// API호출
    private func fetchExhibitionAPI() async {
        exhibitionService.getDetailExhibition(exhibitionId: exhibitionId) { [weak self] result in
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
                        } catch {
                            Log.error("로컬 데이터 로드 실패: \(error)")
                        }
                    }

                case .failure(let error):
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

        let descriptor = FetchDescriptor<Reaction>(
            predicate: #Predicate<Reaction> { reaction in
                reaction.exhibitionId == exhibitionId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let reactions = try context.fetch(descriptor)
        return reactions
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

        artworkService.getArtworkDetail(artworkId: artworkId) { result in
            Task {
                switch result {
                case .success(let artwork):
                    Log.debug("작품 상세 조회 성공! 작품명: \(artwork.title)")
                    // 로컬 데이터 다시 로드
                    self.loadData()
                case .failure(let error):
                    Log.error("작품 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Artwork + Reactions 묶어서 반환
extension ExhibitionArchiveViewModel {
    /// artwork 1개당 카드 1개만 만들어지도록 도와주는 헬퍼
    func getArtworkReactionPairs() -> [(artwork: Artwork, reactions: [Reaction])] {
        let groupedByArtworkId = Dictionary(grouping: reactions, by: { $0.artworkId })

        return artworks.compactMap { artwork in
            guard let reactionsForArtwork = groupedByArtworkId[artwork.id],
                !reactionsForArtwork.isEmpty
            else {
                return nil
            }
            return (artwork, reactionsForArtwork)
        }
    }
}
