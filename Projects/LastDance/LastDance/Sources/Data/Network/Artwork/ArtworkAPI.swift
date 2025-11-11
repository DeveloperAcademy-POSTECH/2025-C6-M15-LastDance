//
//  ArtworkAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Moya

enum ArtworkAPI {
    case getArtworks(artistId: Int?, exhibitionId: Int?)
    case getArtworkDetail(artworkId: Int)
    case makeArtwork(dto: MakeArtworkRequestDto)
}

extension ArtworkAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getArtworks, .makeArtwork:
            return "\(APIVersion.version1)/artworks"
        case let .getArtworkDetail(artworkId):
            return "\(APIVersion.version1)/artworks/\(artworkId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getArtworks, .getArtworkDetail:
            return .get
        case .makeArtwork:
            return .post
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case let .getArtworks(artistId, exhibitionId):
            var params: [String: Any] = [:]
            if let artistId = artistId {
                params["artist_id"] = artistId
            }
            if let exhibitionId = exhibitionId {
                params["exhibition_id"] = exhibitionId
            }
            return params.isEmpty ? nil : params
        case .getArtworkDetail, .makeArtwork:
            return nil
        }
    }

    var bodyParameters: Codable? {
        switch self {
        case .getArtworks, .getArtworkDetail:
            return nil
        case let .makeArtwork(dto):
            return dto
        }
    }
}
