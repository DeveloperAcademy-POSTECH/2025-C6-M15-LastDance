//
//  ArchivingViewModel.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

@MainActor
final class ArchivingViewModel: ObservableObject {
    private let visitorService = VisitorAPIService()

    /// 추가 버튼 탭
    func tapAddButton() {
        // TODO: 전시 추가 또는 다음 화면으로 네비게이션
    }
    
    func loadVisitorAPI() {
        visitorService.getVisitors { result in
            switch result {
            case .success(let list):
                Log.debug("방문자 수: \(list.count)")
            case .failure(let err):
                Log.debug("목록 실패: \(err)")
            }
        }
    }
}
