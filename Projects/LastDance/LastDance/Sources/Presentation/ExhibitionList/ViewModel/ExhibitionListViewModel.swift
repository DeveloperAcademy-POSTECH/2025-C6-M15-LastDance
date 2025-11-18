//
//  ExhibitionListViewModel.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

@MainActor
final class ExhibitionListViewModel: ObservableObject {
    @Published var selectedExhibitionId: Int? = nil
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

    /// 선택된 전시 초기화
    func clearSelection() {
        selectedExhibitionId = nil
    }

    /// 등록하기 버튼 탭
    func tapRegisterButton() {
        guard selectedExhibitionId != nil else {
            // TODO: 전시를 선택하지 않은 경우 예외 처리
            return
        }
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
                    Log.debug("전시 조회 성공: \(exhibitions.count)개")

                case .failure(let error):
                    if let errorDto = error as? ErrorResponseDto {
                        self?.errorMessage =
                            "❌ 실패: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))"
                    } else {
                        self?.errorMessage = "❌ 실패: \(error.localizedDescription)"
                    }
                    Log.error("전시 조회 실패: \(error)")
                }
            }
        }
    }
}
