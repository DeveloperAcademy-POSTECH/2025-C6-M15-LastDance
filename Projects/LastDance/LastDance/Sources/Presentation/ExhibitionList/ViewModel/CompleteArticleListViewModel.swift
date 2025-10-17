//
//  CompleteArticleListViewModel.swift
//  LastDance
//
//  Created by donghee on 10/16/25.
//

import SwiftUI

@MainActor
final class CompleteArticleListViewModel: ObservableObject {
    @Published var exhibition: Exhibition?
    @Published var artist: Artist?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    private let dataManager = SwiftDataManager.shared
    private let apiService: ExhibitionAPIServiceProtocol

    init(apiService: ExhibitionAPIServiceProtocol = ExhibitionAPIService()) {
        self.apiService = apiService
    }
    
    /// 전시 및 작가 정보 가져오기
    func fetchData(exhibitionId: String, artistId: String) {
        isLoading = true
        errorMessage = ""

        // API로 전시 목록을 먼저 가져와서 로컬 DB에 저장
        apiService.getExhibitions(status: nil, venueId: nil) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let exhibitions):
                    Log.debug("[CompleteArticleListViewModel] 전시 조회 성공: \(exhibitions.count)개")

                    // API 응답 후 로컬 DB에서 조회
                    self?.loadDataFromLocal(exhibitionId: exhibitionId, artistId: artistId)

                case .failure(let error):
                    if let errorDto = error as? ErrorResponseDto {
                        self?.errorMessage = "❌ 실패: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))"
                    } else {
                        self?.errorMessage = "❌ 실패: \(error.localizedDescription)"
                    }
                    Log.error("[CompleteArticleListViewModel] 전시 조회 실패: \(error)")
                }
            }
        }
    }

    /// 로컬 DB에서 전시 및 작가 정보 조회
    private func loadDataFromLocal(exhibitionId: String, artistId: String) {
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        let allArtists = dataManager.fetchAll(Artist.self)

        Log.debug("[CompleteArticleListViewModel] 전체 전시 수: \(allExhibitions.count), 전체 작가 수: \(allArtists.count)")
        Log.debug("[CompleteArticleListViewModel] 찾으려는 전시 ID: \(exhibitionId), 작가 ID: \(artistId)")

        exhibition = allExhibitions.first { $0.id == exhibitionId }
        artist = allArtists.first { String($0.id) == artistId }

        Log.debug("[CompleteArticleListViewModel] 로컬 DB 조회 - 전시: \(exhibition?.title ?? "없음"), 작가: \(artist?.name ?? "없음")")
    }
}
