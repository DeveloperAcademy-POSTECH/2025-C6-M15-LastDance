//
//  AlarmViewModel.swift
//  LastDance
//
//  Created by 아우신얀 on 11/10/25.
//

import SwiftUI

@MainActor
final class AlarmViewModel: ObservableObject {
    @Published var hasNotifications = false

    /// 알림 존재 여부 확인
    func checkNotifications() {
        // TODO: 실제 알림 API와 연동하여 알림 존재 여부 확인
        // NotificationAPIService().getNotifications { [weak self] result in
        //     DispatchQueue.main.async {
        //         switch result {
        //         case .success(let notifications):
        //             self?.hasNotifications = !notifications.isEmpty
        //         case .failure:
        //             self?.hasNotifications = false
        //         }
        //     }
        // }

        // 임시로 false 설정
        hasNotifications = false
    }
}
