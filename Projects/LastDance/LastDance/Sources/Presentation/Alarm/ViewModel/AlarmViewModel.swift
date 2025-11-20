//
//  AlarmViewModel.swift
//  LastDance
//
//  Created by 아우신얀 on 11/10/25.
//

import SwiftUI

@MainActor
final class AlarmViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService: NotificationAPIServiceProtocol

    init(apiService: NotificationAPIServiceProtocol = NotificationAPIService()) {
        self.apiService = apiService
    }

    var hasNotifications: Bool {
        return !notifications.isEmpty
    }

    /// 알림 목록 조회
    func loadNotifications(uuid: String, userType: UserType) {
        isLoading = true
        errorMessage = nil

        apiService.getNotificationList(
            uuid: uuid,
            isRead: nil,
            limit: 100,
            offset: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let responseDto):
                    self.notifications = responseDto.map {
                        NotificationItem(from: $0, userType: userType)
                    }
                    Log.debug("알림 목록 로드 성공 - \(self.notifications.count)개")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    Log.error("알림 목록 로드 실패: \(error)")
                }
            }
        }
    }
}
