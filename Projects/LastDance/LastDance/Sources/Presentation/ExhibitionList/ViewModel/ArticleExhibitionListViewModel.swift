//
//  ArticleExhibitionListViewModel.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

@MainActor
final class ArticleExhibitionListViewModel: ObservableObject {
    @Published var exhibitions: [Exhibition] = []
    @Published var selectedExhibitionId: String? = nil

    private let dataManager = SwiftDataManager.shared

    init() {
        fetchExhibitions()
    }

    /// 전시 목록 가져오기
    func fetchExhibitions() {
        exhibitions = dataManager.fetchAll(Exhibition.self)
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

    /// 다음 버튼 탭
    func tapNextButton() -> String? {
        guard let selectedId = selectedExhibitionId else {
            // TODO: 전시를 선택하지 않은 경우 예외 처리
            return nil
        }
        return selectedId
    }
}
