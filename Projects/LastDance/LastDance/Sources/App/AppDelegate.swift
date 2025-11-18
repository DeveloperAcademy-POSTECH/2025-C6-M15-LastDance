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

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Log.debug("푸시 탭 userInfo: \(userInfo)")

        completionHandler()
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

        // DeviceTokenManager를 통해 토큰 저장
        DeviceTokenManager.shared.saveDeviceToken(token)

        // visitorId or artistId가 있으면 DeviceTokenManager를 통해 서버 전송 시도
        DeviceTokenManager.shared.registerDeviceTokenIfNeeded()
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Log.error("APNs 등록 실패: \(error.localizedDescription)")
    }
}
