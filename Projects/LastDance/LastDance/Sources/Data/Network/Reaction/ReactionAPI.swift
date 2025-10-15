//
//  ReactionAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Moya

enum ReactionAPI {
    case createReaction(dto: ReactionRequestDto)
}

extension ReactionAPI: BaseTargetType {
    var path: String {
        switch self {
        case .createReaction:
            return "/api/v1/reactions"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createReaction:
            return .post
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .createReaction:
            return nil
        }
    }
    
    var bodyParameters: Codable? {
        switch self {
        case .createReaction(let dto):
            return dto
        }
    }
}
