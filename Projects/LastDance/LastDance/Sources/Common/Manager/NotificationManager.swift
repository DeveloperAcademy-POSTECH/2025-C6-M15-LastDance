//
//  NotificationManager.swift
//  LastDance
//
//  Created by 아우신얀 on 11/20/25.
//

import Foundation

final class NotificationManager {
    static let shared = NotificationManager()

    private let notificationService = NotificationAPIService()

    private init() {}

    /// 작가에게 푸시알림 전송
    func sendPushNotificationToArtist(artistId: Int, artworkTitle: String? = nil) {
        Log.debug("작가(\(artistId))에게 푸시알림 전송 시작")

        #if DEBUG
            let useSandbox = true
        #else
            let useSandbox = false
        #endif

        let pushDto = SendNotificationRequestDto(
            visitor_id: nil,  // 작가에게만 알림 전송
            artist_id: artistId,
            device_token: nil,
            title: "내 작품에 새로운 메시지가 있어요",
            body: "어떤 메시지인지 확인해보세요!",
            data: nil,
            badge: 1,
            use_sandbox: useSandbox
        )

        notificationService.sendNotification(dto: pushDto) { result in
            switch result {
            case .success(let response):
                Log.debug(
                    "푸시알림 전송 성공 - success: \(response.success_count), failed: \(response.failed_count)"
                )
            case .failure(let error):
                Log.error("푸시알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }

    /// 관람객에게 푸시알림 전송
    func sendPushNotificationToViewer(visitorId: Int, artistName: String, artworkId: Int) {
        Log.debug("관람객(\(visitorId))에게 푸시알림 전송 시작")

        #if DEBUG
            let useSandbox = true
        #else
            let useSandbox = false
        #endif

        let pushDto = SendNotificationRequestDto(
            visitor_id: visitorId,
            artist_id: nil,  // 관람객에게만 알림 전송
            device_token: nil,
            title: "\(artistName) 작가님이 내 메시지에 반응했어요",
            body: "어떤 반응인지 확인해보세요!",
            data: ["artworkId": "\(artworkId)", "type": "artworkReaction"],
            badge: 1,
            use_sandbox: useSandbox
        )

        notificationService.sendNotification(dto: pushDto) { result in
            switch result {
            case .success(let response):
                Log.debug(
                    "푸시알림 전송 성공 - success: \(response.success_count), failed: \(response.failed_count)"
                )
            case .failure(let error):
                Log.error("푸시알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }
}
