//
//  IdentitySelectionViewModel.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

@MainActor
final class IdentitySelectionViewModel: ObservableObject {
    @Published var selectedType: UserType?

    private let dataManager = SwiftDataManager.shared

    /// 작가 선택
    func selectArtist() {
        selectedType = .artist
    }

    /// 관람객 선택
    func selectViewer() {
        selectedType = .viewer
    }

    /// 다음 버튼 탭
    func tapNextButton() {
        guard let selectedType = selectedType else {
            // TODO: 선택하지 않은 경우 예외 처리
            return
        }

        saveUserType(selectedType)
        // TODO: 다음 온보딩 화면으로 네비게이션
    }

    /// 사용자 타입 저장
    private func saveUserType(_ type: UserType) {
        let users = dataManager.fetchAll(User.self)

        if let existingUser = users.first {
            existingUser.role = type.rawValue
            dataManager.saveContext()
        } else {
            let newUser = User(role: type.rawValue)
            dataManager.insert(newUser)
        }
    }
}
