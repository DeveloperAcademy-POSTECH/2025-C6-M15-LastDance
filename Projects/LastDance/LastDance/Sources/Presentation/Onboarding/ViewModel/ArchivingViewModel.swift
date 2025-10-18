//
//  ArchivingViewModel.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import Moya
import SwiftUI

@MainActor
final class ArchivingViewModel: ObservableObject {
    
    private let visitorService = VisitorAPIService()
    private let artistService = ArtistAPIService()

    /// 추가 버튼 탭
    func tapAddButton() {
        // TODO: 전시 추가 또는 다음 화면으로 네비게이션
    }
}
