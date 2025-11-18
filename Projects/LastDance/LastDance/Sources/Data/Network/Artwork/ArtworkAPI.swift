//
//  ArtworkAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation
import Moya

enum ArtworkAPI {
    case getArtworks(artistId: Int?, exhibitionId: Int?)
    case getArtworkDetail(artworkId: Int)
    case makeArtwork(dto: MakeArtworkRequestDto, thumbnailData: Data)
    case matchArtwork(dto: ArtworkMatchRequestDto)
}

extension ArtworkAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getArtworks, .makeArtwork:
            return "\(APIVersion.version1)/artworks"
        case .getArtworkDetail(let artworkId):
            return "\(APIVersion.version1)/artworks/\(artworkId)"
        case .matchArtwork:
            return "\(APIVersion.version1)/artworks/match"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getArtworks, .getArtworkDetail:
            return .get
        case .makeArtwork, .matchArtwork:
            return .post
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .getArtworks(let artistId, let exhibitionId):
            var params: [String: Any] = [:]
            if let artistId = artistId {
                params["artist_id"] = artistId
            }
            if let exhibitionId = exhibitionId {
                params["exhibition_id"] = exhibitionId
            }
            return params.isEmpty ? nil : params
        case .getArtworkDetail, .makeArtwork, .matchArtwork:
            return nil
        }
    }

    var bodyParameters: Codable? {
        switch self {
        case .getArtworks, .getArtworkDetail, .makeArtwork:
            return nil
        case .matchArtwork(let dto):
            return dto
        }
    }

    var isMultipart: Bool {
        switch self {
        case .makeArtwork:
            return true
        default:
            return false
        }
    }

    var multipartData: [Moya.MultipartFormData]? {
        switch self {
        case .makeArtwork(let dto, let thumbnailData):
            var parts: [Moya.MultipartFormData] = []

            func addText(_ name: String, _ value: String) {
                if let data = value.data(using: .utf8) {
                    parts.append(.init(provider: .data(data), name: name))
                }
            }

            addText("title", dto.title)
            addText("artist_id", String(dto.artist_id))

            if let description = dto.description {
                addText("description", description)
            }
            if let year = dto.year {
                addText("year", String(year))
            }

            let thumbnailPart = Moya.MultipartFormData(
                provider: .data(thumbnailData),
                name: "thumbnail",
                fileName: "thumbnail.jpg",
                mimeType: "image/jpeg"
            )
            parts.append(thumbnailPart)

            return parts

        default:
            return nil
        }
    }
}
