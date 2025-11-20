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
    case getNotificationList(
        uuid: String, isRead: Bool? = nil, limit: Int? = nil, offset: Int? = nil)
    case getUnreadNotificationCount(uuid: String)
    case readAllNotification(uuid: String)
}

extension NotificationAPI: BaseTargetType {
    var path: String {
        switch self {
        case .registerDeviceToken:
            return "\(APIVersion.version1)/devices/register-token"
        case .sendNotification:
            return "\(APIVersion.version1)/devices/send-notification"
        case .getNotificationList:
            return "\(APIVersion.version1)/notifications"
        case .getUnreadNotificationCount:
            return "\(APIVersion.version1)/notifications/unread-count"
        case .readAllNotification:
            return "\(APIVersion.version1)/notifications/read-all"
        }
    }

    var method: Moya.Method {
        switch self {
        case .registerDeviceToken, .sendNotification:
            return .post
        case .getNotificationList, .getUnreadNotificationCount:
            return .get
        case .readAllNotification:
            return .patch
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getNotificationList(let uuid, _, _, _), .getUnreadNotificationCount(let uuid),
            .readAllNotification(let uuid):
            var headers = ["Content-Type": HTTPHeaderConstants.contentTypeJSON]
            headers["X-User-UUID"] = uuid
            return headers
        default:
            return ["Content-Type": HTTPHeaderConstants.contentTypeJSON]
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .getNotificationList(_, let isRead, let limit, let offset):
            var params: [String: Any] = [:]

            if let isRead = isRead {
                params["is_read"] = isRead
            }

            if let limit = limit {
                let clampedLimit = max(1, min(100, limit))
                params["limit"] = clampedLimit
            }

            if let offset = offset {
                let clampedOffset = max(0, offset)
                params["offset"] = clampedOffset
            }

            return params.isEmpty ? nil : params
        default:
            return nil
        }
    }

    var bodyParameters: Codable? {
        switch self {
        case .registerDeviceToken(let dto):
            return dto
        case .sendNotification(let dto):
            return dto
        case .getNotificationList, .getUnreadNotificationCount, .readAllNotification:
            return nil
        }
    }
}
