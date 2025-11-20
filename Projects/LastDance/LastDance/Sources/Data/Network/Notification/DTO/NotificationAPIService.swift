//
//  NotificationAPIService.swift
//  LastDance
//
//  Created by 아우신얀 on 11/16/25.
//

import Foundation
import Moya

// MARK: NotificationAPIServiceProtocol

protocol NotificationAPIServiceProtocol {
    func registerDeviceToken(
        dto: RegisterDeviceTokenRequestDto,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func sendNotification(
        dto: SendNotificationRequestDto,
        completion: @escaping (Result<SendNotificationResponseDto, Error>) -> Void
    )

    func getNotificationList(
        uuid: String,
        isRead: Bool?,
        limit: Int?,
        offset: Int?,
        completion: @escaping (Result<NotificationListResponseDto, Error>) -> Void
    )

    func getUnreadNotificationCount(
        uuid: String,
        completion: @escaping (Result<UnreadNotificationCountResponseDto, Error>) -> Void
    )
}

// MARK: NotificationAPIService

final class NotificationAPIService: NotificationAPIServiceProtocol {
    private let provider: MoyaProvider<NotificationAPI>

    init(
        provider: MoyaProvider<NotificationAPI> = MoyaProvider<NotificationAPI>(plugins: [
            NetworkLoggerPlugin()
        ])
    ) {
        self.provider = provider
    }

    /// 디바이스 토큰 등록 함수
    func registerDeviceToken(
        dto: RegisterDeviceTokenRequestDto,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        provider.request(.registerDeviceToken(dto: dto)) { result in
            switch result {
            case .success(let response):
                // 빈 응답 처리 (status code만 확인)
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    Log.debug("서버 응답: \(jsonString)")
                }
                Log.debug("디바이스 토큰 등록 성공")
                completion(.success(()))
            case .failure(let error):
                if let data = error.response?.data,
                    let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 푸시알람 전송 함수
    func sendNotification(
        dto: SendNotificationRequestDto,
        completion: @escaping (Result<SendNotificationResponseDto, Error>) -> Void
    ) {
        provider.request(.sendNotification(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("sendNotification 응답: \(jsonString)")
                    }
                    let responseDto = try JSONDecoder().decode(
                        SendNotificationResponseDto.self,
                        from: response.data
                    )
                    Log.debug(
                        "푸시알림 전송 성공 - success: \(responseDto.success_count), failed: \(responseDto.failed_count)"
                    )
                    completion(.success(responseDto))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                    let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 알림 목록 조회 함수
    func getNotificationList(
        uuid: String,
        isRead: Bool? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        completion: @escaping (Result<NotificationListResponseDto, Error>) -> Void
    ) {
        provider.request(
            .getNotificationList(uuid: uuid, isRead: isRead, limit: limit, offset: offset)
        ) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("getNotificationList 응답: \(jsonString)")
                    }
                    let responseDto = try JSONDecoder().decode(
                        NotificationListResponseDto.self,
                        from: response.data
                    )
                    Log.debug("알림 목록 조회 성공 - \(responseDto.count)개")
                    completion(.success(responseDto))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                    let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 읽지 않은 알림 개수 조회 함수
    func getUnreadNotificationCount(
        uuid: String,
        completion: @escaping (Result<UnreadNotificationCountResponseDto, Error>) -> Void
    ) {
        provider.request(.getUnreadNotificationCount(uuid: uuid)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("getUnreadNotificationCount 응답: \(jsonString)")
                    }
                    let responseDto = try JSONDecoder().decode(
                        UnreadNotificationCountResponseDto.self,
                        from: response.data
                    )
                    Log.debug("읽지 않은 알림 개수 조회 성공 - \(responseDto.count)개")
                    completion(.success(responseDto))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                    let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

}
