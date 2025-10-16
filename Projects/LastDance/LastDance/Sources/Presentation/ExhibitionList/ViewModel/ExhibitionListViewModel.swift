//
//  ExhibitionListViewModel.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

@MainActor
final class ExhibitionListViewModel: ObservableObject {
    @Published var selectedExhibitionId: String? = nil
    @Published var isLoading: Bool = false
    @Published var resultMessage: String = ""
    @Published var errorMessage: String = ""

    private let dataManager = SwiftDataManager.shared
    private let apiService: ExhibitionAPIServiceProtocol

    init(apiService: ExhibitionAPIServiceProtocol = ExhibitionAPIService()) {
        self.apiService = apiService
    }

    /// 전시 선택 (이미 선택된 경우 선택 취소)
    func selectExhibition(_ exhibition: Exhibition) {
        if selectedExhibitionId == exhibition.id {
            selectedExhibitionId = nil
        } else {
            selectedExhibitionId = exhibition.id
        }
    }

    /// 등록하기 버튼 탭
    func tapRegisterButton() {
        guard selectedExhibitionId != nil else {
            // TODO: 전시를 선택하지 않은 경우 예외 처리
            return
        }
        // TODO: 다음 화면으로 네비게이션
    }

    /// 전시 전체 조회 api 연동
    func getExhibitions(status: String? = nil, venueId: Int? = nil) {
        isLoading = true
        resultMessage = ""
        errorMessage = ""

        apiService.getExhibitions(status: status, venueId: venueId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let exhibitions):
                    self?.resultMessage = """
                    ✅ 전시 조회 성공!
                    총 \(exhibitions.count)개의 전시
                    """
                    Log.debug("[ExhibitionListViewModel] 전시 조회 성공: \(exhibitions.count)개")

                case .failure(let error):
                    if let errorDto = error as? ErrorResponseDto {
                        self?.errorMessage = "❌ 실패: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))"
                    } else {
                        self?.errorMessage = "❌ 실패: \(error.localizedDescription)"
                    }
                    Log.error("[ExhibitionListViewModel] 전시 조회 실패: \(error)")
                }
            }
        }
    }

    /// 전시 생성 api 연동
    func makeExhibitionList() {
        isLoading = true
        resultMessage = ""
        errorMessage = ""

        // dataManager에서 첫 번째 Artwork 가져오기
        let artworks = dataManager.fetchAll(Artwork.self)
        guard let firstArtwork = artworks.first,
              let artistId = firstArtwork.artistId else {
            errorMessage = "❌ 실패: 로컬에 Artwork 데이터가 없거나 artistId가 없습니다."
            isLoading = false
            return
        }

        let testDto = ExhibitionRequestDto(
            title: firstArtwork.title,
            artist_id: artistId,
            description: "Test exhibition created from local data",
            year: 2025,
            thumbnail_url: firstArtwork.thumbnailURL
        )

        apiService.makeExhibition(dto: testDto) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    self?.resultMessage = """
                    ✅ 성공!
                    ID: \(response.id)
                    Title: \(response.title)
                    Artist: \(response.artist.name)
                    Exhibitions: \(response.exhibitions.count)개
                    """
                    Log.debug("[ExhibitionListViewModel] API 성공: \(response)")

                case .failure(let error):
                    if let errorDto = error as? ErrorResponseDto {
                        self?.errorMessage = "❌ 실패: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))"
                    } else {
                        self?.errorMessage = "❌ 실패: \(error.localizedDescription)"
                    }
                    Log.error("[ExhibitionListViewModel] API 실패: \(error)")
                }
            }
        }
    }
}
