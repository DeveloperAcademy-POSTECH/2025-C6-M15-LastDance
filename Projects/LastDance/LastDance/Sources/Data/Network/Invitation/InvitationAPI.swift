//
//  InvitationAPI.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import Foundation
import Moya

enum InvitationAPI {
    case getInvitations
    case createInvitation(dto: InvitationRequestDto)
    case deleteInvitation(invitation_id: Int)
    case getInvitationByCode(code: String)
    case createInvitationInterest(dto: InvitationInterestRequestDto)
}

extension InvitationAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getInvitations, .createInvitation:
            return "\(APIVersion.version1)\(APIVersion.version1)/invitations/"
        case .deleteInvitation(let invitation_id):
            return "\(APIVersion.version1)\(APIVersion.version1)/invitations/\(invitation_id)"
        case .getInvitationByCode(let code):
            return "\(APIVersion.version1)\(APIVersion.version1)/invitations/code/\(code)"
        case .createInvitationInterest:
            return "\(APIVersion.version1)\(APIVersion.version1)/invitations/interests"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getInvitations, .getInvitationByCode:
            return .get
        case .createInvitation, .createInvitationInterest:
            return .post
        case .deleteInvitation:
            return .delete
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = ["Content-Type": HTTPHeaderConstants.contentTypeJSON]

        switch self {
        case .createInvitationInterest:
            // X-User-UUID 헤더 추가 (관람객)
            if let visitorUUID = UserDefaults.standard.string(
                forKey: UserDefaultsKey.visitorUUID.rawValue)
            {
                headers["X-User-UUID"] = visitorUUID
                Log.debug("InvitationAPI - X-User-UUID 헤더 설정: \(visitorUUID)")
            } else {
                Log.error("InvitationAPI - visitorUUID를 UserDefaults에서 찾을 수 없습니다.")
            }
        default:
            // X-Artist-UUID 헤더 추가 (작가)
            if let artistUUID = UserDefaults.standard.string(
                forKey: UserDefaultsKey.artistUUID.rawValue)
            {
                headers["X-Artist-UUID"] = artistUUID
                Log.debug("InvitationAPI - X-Artist-UUID 헤더 설정: \(artistUUID)")
            } else {
                Log.error("InvitationAPI - artistUUID를 UserDefaults에서 찾을 수 없습니다.")
            }
        }

        return headers
    }

    var queryParameters: [String: Any]? {
        return nil
    }

    var bodyParameters: Codable? {
        switch self {
        case .getInvitations, .deleteInvitation, .getInvitationByCode:
            return nil
        case .createInvitation(let dto):
            return dto
        case .createInvitationInterest(let dto):
            return dto
        }
    }
}
