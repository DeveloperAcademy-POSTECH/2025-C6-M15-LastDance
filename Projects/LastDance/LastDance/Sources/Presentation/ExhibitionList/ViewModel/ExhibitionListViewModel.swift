//
//  ExhibitionListViewModel.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

@MainActor
final class ExhibitionListViewModel: ObservableObject {
    @Published var exhibitions: [Exhibition] = []
    @Published var selectedExhibitionId: String? = nil

    private let dataManager = SwiftDataManager.shared

    init() {
        fetchExhibitions()
    }

    /// 전시 목록 가져오기
    func fetchExhibitions() {
        exhibitions = dataManager.fetchAll(Exhibition.self)
        Log.debug("📊 Fetched \(exhibitions.count) exhibitions")
        exhibitions.forEach { exhibition in
            Log.debug("  - \(exhibition.title)")
        }
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
}
