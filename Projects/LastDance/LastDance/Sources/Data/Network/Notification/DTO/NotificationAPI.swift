//
//  NotificationAPI.swift
//  LastDance
//
//  Created by 아우신얀 on 11/16/25.
//

import Moya

enum NotificationAPI {
    case registerDeviceToken(dto: RegisterDeviceTokenRequestDto)
    case sendNotification(dto: SendNotificationRequestDto)
}

extension NotificationAPI: BaseTargetType {
    var path: String {
        switch self {
        case .registerDeviceToken:
            return "\(APIVersion.version1)/devices/register-token"
        case .sendNotification:
            return "\(APIVersion.version1)/devices/send-notification"
        }
    }

    var method: Moya.Method {
        switch self {
        case .registerDeviceToken, .sendNotification:
            return .post
        }
    }

    var queryParameters: [String: Any]? {
        return nil
    }

    var bodyParameters: Codable? {
        switch self {
        case .registerDeviceToken(let dto):
            return dto
        case .sendNotification(let dto):
            return dto
        }
    }
}
