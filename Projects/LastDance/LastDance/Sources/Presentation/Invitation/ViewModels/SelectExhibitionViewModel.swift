//
//  SelectExhibitionViewModel.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import Foundation
import SwiftUI

final class SelectExhibitionViewModel: ObservableObject {
    @Published var exhibitions: [Exhibition] = []
    @Published var selectedExhibition: Exhibition?
    @Published var isLoading = false

    private let apiService: ExhibitionAPIService

    init(apiService: ExhibitionAPIService = ExhibitionAPIService()) {
        self.apiService = apiService
    }

    var isInviteEnabled: Bool {
        selectedExhibition != nil
    }

    func loadActiveExhibitions() {
        isLoading = true

        // 현재 로그인한 작가의 ID 가져오기
        guard
            let artistId = UserDefaults.standard.object(forKey: UserDefaultsKey.artistId.rawValue)
                as? Int
        else {
            Log.error("작가 ID를 찾을 수 없습니다. 작가 인증이 필요합니다.")
            isLoading = false
            exhibitions = []
            return
        }

        apiService.getExhibitions(status: "active", venueId: nil) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let exhibitionDtos):
                    // 현재 작가의 전시만 필터링
                    let myExhibitions = exhibitionDtos.filter { dto in
                        // artists 배열에서 현재 작가 ID가 있는지 확인
                        if let artists = dto.artists {
                            return artists.contains { $0.id == artistId }
                        }
                        return false
                    }

                    // DTO를 Exhibition 모델로 변환
                    let exhibitions = myExhibitions.map { $0.toEntity() }
                    self?.exhibitions = exhibitions
                    Log.debug("작가 ID \(artistId)의 전시 \(exhibitions.count)개 로드 완료")
                case .failure(let error):
                    Log.error("전시 조회 실패: \(error)")
                    self?.exhibitions = []
                }
            }
        }
    }

    func selectExhibition(_ exhibition: Exhibition) {
        if selectedExhibition?.id == exhibition.id {
            selectedExhibition = nil
        } else {
            selectedExhibition = exhibition
        }
    }

    func getSelectedExhibition() -> Exhibition? {
        return selectedExhibition
    }
}
