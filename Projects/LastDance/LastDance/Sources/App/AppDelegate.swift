//
//  AppDelegate.swift
//  LastDance
//
//  Created by 아우신얀 on 11/16/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. 푸시 권한 요청
        UNUserNotificationCenter.current().delegate = self
        requestAuthorization()

        // 2. 앱이 종료된 상태에서 푸시 알림을 탭해서 실행된 경우 처리
        if let remoteNotification = launchOptions?[.remoteNotification] as? [String: Any] {
            Log.debug("앱 종료 상태에서 푸시로 실행됨: \(remoteNotification)")
            handlePushNotificationData(remoteNotification)
        }

        return true
    }

    /// 푸시 권한 요청 함수
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                Log.warning("푸시 권한 거부")
            }
        }
    }

    /// 앱이 포그라운드에 수신하면 푸시 알람 보내도록
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        Log.debug("실시간 푸시 수신 userInfo: \(userInfo)")

        completionHandler([.banner, .sound, .badge])
    }

    /// 푸시 알람 받았을때 딥링크 처리 로직
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Log.debug("푸시 탭 userInfo 전체: \(userInfo)")

        // userInfo의 모든 키-값 쌍 출력
        for (key, value) in userInfo {
            Log.debug("  - \(key): \(value)")
        }

        handlePushNotificationData(userInfo)
        completionHandler()
    }

    /// 푸시 알림 데이터를 처리하여 딥링크 실행
    private func handlePushNotificationData(_ userInfo: [AnyHashable: Any]) {
        // 1. 최상위 레벨에서 deep_link 확인
        if let deepLinkString = userInfo["deep_link"] as? String,
            let deepLinkURL = URL(string: deepLinkString)
        {
            Log.debug("✅ 최상위 deep_link 발견: \(deepLinkURL.absoluteString)")
            triggerDeepLink(deepLinkURL)
            return
        }

        // 2. aps.data 내부에서 deep_link 확인
        if let aps = userInfo["aps"] as? [String: Any],
            let data = aps["data"] as? [String: Any],
            let deepLinkString = data["deep_link"] as? String,
            let deepLinkURL = URL(string: deepLinkString)
        {
            Log.debug("✅ aps.data.deep_link 발견: \(deepLinkURL.absoluteString)")
            triggerDeepLink(deepLinkURL)
            return
        }

        // 3. data 필드에서 deep_link 확인
        if let data = userInfo["data"] as? [String: Any],
            let deepLinkString = data["deep_link"] as? String,
            let deepLinkURL = URL(string: deepLinkString)
        {
            Log.debug("✅ data.deep_link 발견: \(deepLinkURL.absoluteString)")
            triggerDeepLink(deepLinkURL)
            return
        }

        // 4. type과 artwork_id로 딥링크 생성
        if let type = userInfo["type"] as? String {
            // 작가에게 온 반응 알림
            if type == "reaction_to_artist",
                let artworkId = userInfo["artwork_id"] as? Int
            {
                let deepLinkURL = URL(
                    string:
                        "\(PushDeepLinkConstants.scheme)://\(PushDeepLinkConstants.artworkReactionHost)/\(artworkId)"
                )!
                Log.debug(
                    "✅ reaction_to_artist - artwork_id로 딥링크 생성: \(deepLinkURL.absoluteString)")
                triggerDeepLink(deepLinkURL)
                return
            }

            // 관람객에게 온 작가 반응 알림
            if type == "artist_reply",
                let artworkId = userInfo["artwork_id"] as? Int
            {
                let deepLinkURL = URL(
                    string:
                        "\(PushDeepLinkConstants.scheme)://\(PushDeepLinkConstants.artworkReactionHost)/\(artworkId)"
                )!
                Log.debug("✅ artist_reply - artwork_id로 딥링크 생성: \(deepLinkURL.absoluteString)")
                triggerDeepLink(deepLinkURL)
                return
            }
        }

        // 5. artwork_id만 있는 경우 (폴백)
        if let artworkId = userInfo["artwork_id"] as? Int {
            let deepLinkURL = URL(
                string:
                    "\(PushDeepLinkConstants.scheme)://\(PushDeepLinkConstants.artworkReactionHost)/\(artworkId)"
            )!
            Log.debug("✅ artwork_id로 딥링크 생성: \(deepLinkURL.absoluteString)")
            triggerDeepLink(deepLinkURL)
            return
        }

        Log.error("❌ deep_link를 생성할 수 없음. userInfo: \(userInfo)")
    }

    /// 딥링크를 RootView로 전달
    private func triggerDeepLink(_ url: URL) {
        // 약간의 지연을 두고 딥링크 실행 (UI가 준비될 시간 확보)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: NSNotification.Name("HandleDeepLink"),
                object: nil,
                userInfo: ["url": url]
            )
        }
    }
}

// MARK: - APNs 등록 처리

extension AppDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        Log.debug("📲 APNs 토큰 수신: \(token)")

        DeviceTokenManager.shared.saveDeviceToken(token)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Log.error("APNs 등록 실패: \(error.localizedDescription)")
    }
}
