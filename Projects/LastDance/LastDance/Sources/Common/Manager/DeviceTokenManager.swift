//
//  DeviceTokenManager.swift
//  LastDance
//
//  Created by 아우신얀 on 11/18/25.
//

import Foundation

final class DeviceTokenManager {
    static let shared = DeviceTokenManager()

    private let notificationService = NotificationAPIService()

    private init() {}

    /// 디바이스 토큰을 UserDefaults에 저장
    func saveDeviceToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "deviceToken")
        Log.debug("디바이스 토큰 저장 완료: \(token)")
    }

    /// 디바이스 토큰이 있고 visitorId/artistId가 있으면 서버로 전송
    func registerDeviceTokenIfNeeded() {
        if UserDefaults.standard.bool(forKey: "hasRegisteredDeviceToken") {
            Log.debug("디바이스 토큰 이미 등록됨")
            return
        }

        // UserDefaults에서 저장된 디바이스 토큰 가져오기
        guard let token = UserDefaults.standard.string(forKey: "deviceToken") else {
            Log.debug("디바이스 토큰 없음 -> 나중에 등록 예정")
            return
        }

        let visitorId = UserDefaults.standard.integer(forKey: UserDefaultsKey.visitorId.rawValue)
        let artistId = UserDefaults.standard.integer(forKey: UserDefaultsKey.artistId.rawValue)

        // 둘 다 없으면 전송 불가
        guard visitorId != 0 || artistId != 0 else {
            Log.debug("visitorId/artistId 없음")
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
                // 등록 성공 시 플래그 저장하여 중복 등록 방지
                UserDefaults.standard.set(true, forKey: "hasRegisteredDeviceToken")
                Log.debug("서버에 디바이스 토큰 등록 성공 (최초 1회)")
            case .failure(let error):
                Log.error("서버에 디바이스 토큰 전송 실패: \(error.localizedDescription)")
            }
        }
    }
}
