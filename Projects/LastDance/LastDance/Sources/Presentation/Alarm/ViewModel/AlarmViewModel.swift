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
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService: NotificationAPIServiceProtocol

    init(apiService: NotificationAPIServiceProtocol = NotificationAPIService()) {
        self.apiService = apiService
    }

    var hasNotifications: Bool {
        return unreadCount > 0
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

    /// UUID 가져오기
    private func getUUID(for userType: UserType) -> String? {
        let uuid: String?
        switch userType {
        case .artist:
            uuid = UserDefaults.standard.string(forKey: UserDefaultsKey.artistUUID.key)
        case .viewer:
            uuid = UserDefaults.standard.string(forKey: UserDefaultsKey.visitorUUID.key)
        }
        return uuid
    }

    /// 알림 화면 진입 시 호출
    func onAlarmViewAppear(userType: UserType) {
        guard let uuid = getUUID(for: userType), !uuid.isEmpty else {
            Log.info("UUID가 없습니다.")
            return
        }

        loadNotifications(uuid: uuid, userType: userType)
        markAllAsRead(uuid: uuid)
    }

    /// 딥링크 처리
    func handleNotificationTap(
        _ item: NotificationItem, router: NavigationRouter, userType: UserType
    ) {
        if !item.deepLink.isEmpty, let deepLinkURL = URL(string: item.deepLink) {
            router.handleDeepLink(deepLinkURL)
        } else {
            switch userType {
            case .artist:
                router.push(.response(artworkId: item.artworkId))
            case .viewer:
                let artworks = SwiftDataManager.shared.fetchAll(Artwork.self)
                if let artwork = artworks.first(where: { $0.id == item.artworkId }) {
                    let artists = SwiftDataManager.shared.fetchAll(Artist.self)
                    let artist = artists.first(where: { $0.id == artwork.artistId })
                    router.push(.artReaction(artwork: artwork, artist: artist))
                }
            }
        }
    }

    /// 읽지 않은 알림 개수 조회
    func loadUnreadCount(uuid: String) {
        apiService.getUnreadNotificationCount(uuid: uuid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let responseDto):
                    self.unreadCount = responseDto.count
                    Log.debug("읽지 않은 알림 개수: \(responseDto.count)개")
                case .failure(let error):
                    Log.error("읽지 않은 알림 개수 조회 실패: \(error)")
                }
            }
        }
    }

    /// 모든 알림 읽음 처리
    func markAllAsRead(uuid: String) {
        apiService.readAllNotification(uuid: uuid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success:
                    Log.debug("모든 알림 읽음 처리 완료")
                    self.unreadCount = 0
                case .failure(let error):
                    Log.error("모든 알림 읽음 처리 실패: \(error)")
                }
            }
        }
    }
}
