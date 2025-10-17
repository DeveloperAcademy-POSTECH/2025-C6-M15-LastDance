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
    }
}
