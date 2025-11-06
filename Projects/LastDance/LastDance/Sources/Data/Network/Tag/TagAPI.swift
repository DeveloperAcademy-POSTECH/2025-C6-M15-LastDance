//
//  TagAPI.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

import Moya

enum TagAPI {
    case getTags(categoryId: Int? = nil)
    case getTag(id: Int)
}

extension TagAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getTags:
            return "\(APIVersion.version1)/tags"
        case .getTag(let id):
            return "\(APIVersion.version1)/tags/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getTags, .getTag:
            return .get
        }
    }

    var queryParameters: [String : Any]? {
        switch self {
        case .getTags(let categoryId):
            guard let categoryId else { return nil }
            return ["category_id": categoryId]
        case .getTag:
            return nil
        }
    }

    var bodyParameters: Codable? {
        nil
    }
}
