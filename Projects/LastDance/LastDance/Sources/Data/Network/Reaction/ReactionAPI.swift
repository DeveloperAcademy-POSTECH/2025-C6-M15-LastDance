//
//  ReactionAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Moya

enum ReactionAPI {
    case createReaction(dto: ReactionRequestDto)
    case getReactions(artworkId: Int?, visitorId: Int?, visitId: Int?)
    case getDetailReaction(reactionId: Int)
}

extension ReactionAPI: BaseTargetType {
    var path: String {
        switch self {
        case .createReaction, .getReactions:
            return "\(APIVersion.version1)/reactions"
        case let .getDetailReaction(reactionId):
            return "\(APIVersion.version1)/reactions/\(reactionId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createReaction:
            return .post
        case .getReactions, .getDetailReaction:
            return .get
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .createReaction, .getDetailReaction:
            return nil
        case let .getReactions(artworkId, visitorId, visitId):
            var params: [String: Any] = [:]
            if let artworkId = artworkId {
                params["artwork_id"] = artworkId
            }
            if let visitorId = visitorId {
                params["visitor_id"] = visitorId
            }
            if let visitId = visitId {
                params["visit_id"] = visitId
            }
            return params.isEmpty ? nil : params
        }
    }

    var bodyParameters: Codable? {
        switch self {
        case let .createReaction(dto):
            return dto
        case .getReactions, .getDetailReaction:
            return nil
        }
    }
}
