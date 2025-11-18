//
//  DeviceTokenManager.swift
//  LastDance
//
//  Created by Claude on 11/18/25.
//

import Foundation

final class DeviceTokenManager {
    static let shared = DeviceTokenManager()

    private let notificationService = NotificationAPIService()

    private init() {}

    /// 디바이스 토큰을 UserDefaults에 저장
    func saveDeviceToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "deviceToken")
        Log.debug("📲 디바이스 토큰 저장 완료: \(token)")
    }

    /// 디바이스 토큰이 있고 visitorId/artistId가 있으면 서버로 전송
    func registerDeviceTokenIfNeeded() {
        // UserDefaults에서 저장된 디바이스 토큰 가져오기
        guard let token = UserDefaults.standard.string(forKey: "deviceToken") else {
            Log.debug("저장된 디바이스 토큰이 없음 → 전송 생략")
            return
        }

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
        sendDeviceTokenToServer(visitorId: visitorId, artistId: artistId, token: token)
    }

    /// 디바이스 토큰을 서버로 전송하는 내부 함수
    private func sendDeviceTokenToServer(visitorId: Int, artistId: Int, token: String) {
        let dto = RegisterDeviceTokenRequestDto(
            visitorId: visitorId == 0 ? nil : visitorId,
            artistId: artistId == 0 ? nil : artistId,
            deviceToken: token
        )
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
}
