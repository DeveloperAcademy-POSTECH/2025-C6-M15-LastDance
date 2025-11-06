//
//  TagCategoryAPI.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

import Moya

enum TagCategoryAPI {
    case getTagCategories
    case getTagCategory(id: Int)
}

extension TagCategoryAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getTagCategories:
            return "\(APIVersion.version1)/tag-categories"
        case .getTagCategory(let id):
            return "\(APIVersion.version1)/tag-categories/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getTagCategories, .getTagCategory:
            return .get
        }
    }

    var queryParameters: [String : Any]? {
        nil
    }
    
    var bodyParameters: Codable? {
        nil
    }
}
