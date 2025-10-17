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
    private let exhibitionId: Int
    let exhibition: Exhibition

    init(apiService: ExhibitionAPIServiceProtocol = ExhibitionAPIService(), exhibitionId: Int) {
        self.apiService = apiService
        self.exhibitionId = exhibitionId

        // 로컬에서 Exhibition 조회, 없으면 임시 객체 생성
        if let localExhibition = swiftDataManager.fetchById(Exhibition.self, id: String(exhibitionId)) {
            self.exhibition = localExhibition
        } else {
            // 임시 Exhibition 객체 생성 (API 호출 전까지 사용)
            self.exhibition = Exhibition(
                id: String(exhibitionId),
                title: "로딩 중...",
                startDate: Date(),
                endDate: Date()
            )
        }
    }
    
    func loadData() {
        isLoading = true
        errorMessage = ""

        // 로컬 데이터 로드
        Task { @MainActor in
            do {
                self.reactions = try await fetchReactions()
                self.artworks  = try await fetchArtworks()
                self.artists   = try await fetchArtists()
            } catch {
                Log.error("[ExhibitionArchiveViewModel] 로컬 데이터 로드 실패: \(error)")
            }
        }

        // API에서 전시 상세 조회
        apiService.getDetailExhibition(exhibitionId: exhibitionId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let exhibitionDto):
                    Log.debug("[ExhibitionArchiveViewModel] 전시 상세 조회 성공: \(exhibitionDto.title)")

                case .failure(let error):
                    self?.errorMessage = "전시 정보를 불러오는데 실패했습니다."
                    Log.error("[ExhibitionArchiveViewModel] 전시 상세 조회 실패: \(error)")
                }
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

