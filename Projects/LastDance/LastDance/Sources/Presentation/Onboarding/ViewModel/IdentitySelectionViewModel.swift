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

    /// 사용자 타입 선택
    func selectUserType(_ type: UserType) {
        selectedType = type
    }

    /// 선택 확정 및 저장
    func confirmSelection() {
        guard let selectedType = selectedType else {
            // TODO: 선택하지 않은 경우 예외 처리
            return
        }

        saveUserType(selectedType)
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
        UserDefaults.standard.set(type.rawValue, forKey: UserDefaultsKey.userType.key)
    }
}
