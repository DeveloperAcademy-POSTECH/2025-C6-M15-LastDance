//
//  VisitorAPI.swift
//  LastDance
//
//  Created by 배현진 on 10/17/25.
//

import Moya

enum VisitorAPI {
    case getVisitors
    case createVisitor(dto: VisitorCreateRequestDto)
    case getVisitor(id: Int)
    case getVisitorByUUID(uuid: String)
}

extension VisitorAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getVisitors, .createVisitor:
            return "\(APIVersion.version1)/visitors"
        case let .getVisitor(id):
            return "\(APIVersion.version1)/visitors/\(id)"
        case let .getVisitorByUUID(uuid):
            return "\(APIVersion.version1)/visitors/uuid/\(uuid)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getVisitors, .getVisitor, .getVisitorByUUID:
            return .get
        case .createVisitor:
            return .post
        }
    }

    var queryParameters: [String: Any]? {
        return nil
    }

    var bodyParameters: Codable? {
        switch self {
        case let .createVisitor(dto):
            return dto
        default:
            return nil
        }
    }
}
