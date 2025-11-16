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

        // 토큰을 UserDefaults에 저장 (로그인 후에 사용)
        UserDefaults.standard.set(token, forKey: "deviceToken")

        // visitorId, artistId 가져오기
        let visitorId = UserDefaults.standard.integer(forKey: UserDefaultsKey.visitorId.rawValue)
        let artistId = UserDefaults.standard.integer(forKey: UserDefaultsKey.artistId.rawValue)

        Log.debug("visitorId: \(visitorId), artistId: \(artistId)")

        // visitorId나 artistId가 없으면 나중에 전송
        guard visitorId != 0 || artistId != 0 else {
            Log.debug("visitorId/artistId가 없음 -> 로그인 후 전송 예정")
            return
        }

        // 이미 업로드된 경우 생략
        let hasUploaded = UserDefaults.standard.bool(forKey: "hasUploadedDeviceToken")
        guard !hasUploaded else {
            Log.debug("이미 업로드된 토큰일 경우 서버 전송 생략")
            return
        }

        // 서버로 디바이스 토큰 전송
        sendDeviceTokenToServer(visitorId: visitorId, artistId: artistId, token: token)
    }

    /// 외부에서 호출 가능한 public 함수 (visitor/artist 생성 후 호출)
    func registerDeviceTokenIfNeeded() {
        Log.debug("registerDeviceTokenIfNeeded 호출됨")

        // UserDefaults에서 저장된 디바이스 토큰 가져오기
        guard let token = UserDefaults.standard.string(forKey: "deviceToken") else {
            Log.debug("저장된 디바이스 토큰이 없음 → 전송 생략")
            return
        }

        Log.debug("디바이스 토큰 확인: \(token)")

        let visitorId = UserDefaults.standard.integer(forKey: UserDefaultsKey.visitorId.rawValue)
        let artistId = UserDefaults.standard.integer(forKey: UserDefaultsKey.artistId.rawValue)

        Log.debug("체크: visitorId=\(visitorId), artistId=\(artistId)")

        // 둘 다 없으면 전송 불가
        guard visitorId != 0 || artistId != 0 else {
            Log.debug("visitorId/artistId가 없어서 전송 불가")
            return
        }

        // 이미 업로드된 경우 생략
        let hasUploaded = UserDefaults.standard.bool(forKey: "hasUploadedDeviceToken")
        Log.debug("hasUploaded: \(hasUploaded)")

        guard !hasUploaded else {
            Log.debug("이미 업로드된 토큰 → 서버 전송 생략")
            return
        }

        Log.debug("디바이스 토큰 서버 전송 시작")
        sendDeviceTokenToServer(visitorId: visitorId, artistId: artistId, token: token)
    }

    /// 디바이스 토큰을 서버로 전송하는 내부 함수
    private func sendDeviceTokenToServer(visitorId: Int, artistId: Int, token: String) {
        let dto = RegisterDeviceTokenRequestDto(
            visitorId: visitorId == 0 ? nil : visitorId,
            artistId: artistId == 0 ? nil : artistId,
            deviceToken: token
        )

        let notificationService = NotificationAPIService()

        notificationService.registerDeviceToken(dto: dto) { result in
            switch result {
            case .success:
                Log.debug("서버에 디바이스 토큰 등록 성공")
                UserDefaults.standard.set(true, forKey: "hasUploadedDeviceToken")
            case .failure(let error):
                Log.error("서버에 디바이스 토큰 전송 실패: \(error.localizedDescription)")
            }
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Log.error("APNs 등록 실패: \(error.localizedDescription)")
    }
}
