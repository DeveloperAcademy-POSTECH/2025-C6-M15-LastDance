//
//  ReactionAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation
import Moya

enum ReactionAPI {
    case createReaction(dto: ReactionRequestDto)
    case getReactions(artworkId: Int?, visitorId: Int?, visitId: Int?)
    case getDetailReaction(reactionId: Int)
    case createEmojiReaction(reactionId: Int, artistUUID: String, dto: EmojiReactionRequestDto)
    case createMessageReaction(reactionId: Int, artistUUID: String, dto: MessageReactionRequestDto)
}

extension ReactionAPI: BaseTargetType {
    var path: String {
        switch self {
        case .createReaction, .getReactions:
            return "\(APIVersion.version1)/reactions"
        case .getDetailReaction(let reactionId):
            return "\(APIVersion.version1)/reactions/\(reactionId)"
        case .createEmojiReaction(let reactionId, _, _):
            return "\(APIVersion.version1)/reactions/\(reactionId)/artist-emoji"
        case .createMessageReaction(let reactionId, _, _):
            return "\(APIVersion.version1)/reactions/\(reactionId)/artist-messages"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createReaction, .createEmojiReaction, .createMessageReaction:
            return .post
        case .getReactions, .getDetailReaction:
            return .get
        }
    }

    var headers: [String: String]? {
        switch self {
        case .createEmojiReaction(_, let artistUUID, _),
            .createMessageReaction(_, let artistUUID, _):
            return [
                "Content-Type": HTTPHeaderConstants.contentTypeJSON,
                "X-Artist-UUID": artistUUID,
            ]
        default:
            if isMultipart {
                return nil
            }
            return ["Content-Type": HTTPHeaderConstants.contentTypeJSON]
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .createReaction, .getDetailReaction, .createEmojiReaction, .createMessageReaction:
            return nil
        case .getReactions(let artworkId, let visitorId, let visitId):
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
        case .createReaction, .getReactions, .getDetailReaction:
            return nil
        case .createEmojiReaction(_, _, let dto):
            return dto
        case .createMessageReaction(_, _, let dto):
            return dto
        }
    }

    var isMultipart: Bool {
        switch self {
        case .createReaction:
            return true
        default:
            return false
        }
    }

    var multipartData: [Moya.MultipartFormData]? {
        switch self {
        case .createReaction(let dto):
            var parts: [Moya.MultipartFormData] = []

            func addText(_ name: String, _ value: String) {
                if let data = value.data(using: .utf8) {
                    parts.append(.init(provider: .data(data), name: name))
                }
            }

            addText("visitor_id", String(dto.visitorId))
            addText("artwork_id", String(dto.artworkId))
            addText("visit_id", String(dto.visitId))

            if let comment = dto.comment, !comment.isEmpty {
                addText("comment", comment)
            }

            if let tagIds = dto.tagIds,
                let jsonData = try? JSONEncoder().encode(tagIds),
                let jsonString = String(data: jsonData, encoding: .utf8)
            {
                addText("tag_ids", jsonString)
            }

            if let imageData = dto.imageData {
                let part = Moya.MultipartFormData(
                    provider: .data(imageData),
                    name: "image",
                    fileName: "reaction.jpg",
                    mimeType: "image/jpeg"
                )
                parts.append(part)
            }

            return parts

        default:
            return nil
        }
    }
}
