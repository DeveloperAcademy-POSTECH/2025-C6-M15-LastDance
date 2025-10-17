//
//  ArtworkAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Moya

enum ArtworkAPI {
    case getArtworks(artistId: Int?, exhibitionId: Int?)
    case makeArtwork(dto: MakeArtworkRequestDto)
}

extension ArtworkAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getArtworks(let artistId, let exhibitionId), .makeArtwork:
            return "\(APIVersion.v1API)/artworks"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getArtworks:
            return .get
        case .makeArtwork:
            return .post
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .getArtworks(let artistId, let exhibitionId):
            var params: [String: Any] = [:]
            if let artistId = artist_id {
                params["artist_id"] = artist_id
            }
            if let exhibitionId = exhibition_id {
                params["exhibition_id"] = exhibition_id
            }
            return params.isEmpty ? nil : params
        case .makeArtwork:
            return nil
        }
    }
    
    var bodyParameters: Codable? {
        switch self {
        case .getArtworks:
            return nil
        case .makeArtwork(let dto):
            return dto
        }
    }
}


