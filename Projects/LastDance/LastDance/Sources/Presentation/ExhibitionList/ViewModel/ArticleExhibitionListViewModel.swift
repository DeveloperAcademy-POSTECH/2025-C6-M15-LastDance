//
//  ArticleExhibitionListViewModel.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

@MainActor
final class ArticleExhibitionListViewModel: ObservableObject {
    @Published var selectedExhibitionId: Int? = nil
    @Published var isLoading: Bool = false
    @Published var resultMessage: String = ""
    @Published var errorMessage: String = ""

    private let exhibitionAPIService: ExhibitionAPIServiceProtocol
    private let artistAPIService: ArtistAPIServiceProtocol

    init(
        exhibitionAPIService: ExhibitionAPIServiceProtocol = ExhibitionAPIService(),
        artistAPIService: ArtistAPIServiceProtocol = ArtistAPIService()
    ) {
        self.exhibitionAPIService = exhibitionAPIService
        self.artistAPIService = artistAPIService
    }

    /// 전시 선택 (이미 선택된 경우 선택 취소)
    func selectExhibition(_ exhibition: Exhibition) {
        if selectedExhibitionId == exhibition.id {
            selectedExhibitionId = nil
        } else {
            selectedExhibitionId = exhibition.id
        }
    }

    /// 다음 버튼 탭
    func tapNextButton() -> Int? {
        guard let selectedId = selectedExhibitionId else {
            // TODO: 전시를 선택하지 않은 경우 예외 처리
            return nil
        }
        return selectedId
    }

    /// 전시 전체 조회 api 연동
    func loadAllExhibitions(status: String? = nil, venueId: Int? = nil) {
        isLoading = true
        resultMessage = ""
        errorMessage = ""

        exhibitionAPIService.getExhibitions(status: status, venueId: venueId) {
            [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let exhibitions):
                    self.resultMessage = "성공. 총 \(exhibitions.count)개의 전시"
                    Log.debug("전시 조회 성공: \(exhibitions.count)개")

                case .failure(let error):
                    if let errorDto = error as? ErrorResponseDto {
                        self.errorMessage =
                            "실패: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))"
                    } else {
                        self.errorMessage = "실패: \(error.localizedDescription)"
                    }
                    Log.error("전시 조회 실패: \(error)")
                }
            }
        }
    }

    /// 서버에 있는 모든 작가 정보 로드 (확인용)
    func loadAllArtists(onComplete _: (() -> Void)? = nil) {
        artistAPIService.getArtists { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let list):
                    Log.debug("성공. count=\(list.count)")
                case .failure(let error):
                    if let errorDto = error as? ErrorResponseDto {
                        self.errorMessage =
                            "실패: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))"
                    } else {
                        self.errorMessage = "실패: \(error.localizedDescription)"
                    }
                    Log.error("작가 조회 실패: \(error)")
                }
            }
        }
    }
}
