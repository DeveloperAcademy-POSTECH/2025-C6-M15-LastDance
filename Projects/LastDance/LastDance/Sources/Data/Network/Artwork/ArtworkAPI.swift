//
//  ArtworkAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Moya

enum ArtworkAPI {
    case getArtworks(artist_id: Int?, exhibition_id: Int?)
}

extension ArtworkAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getArtworks(let artist_id, let exhibition_id):
            return "\(APIVersion.v1API)/artworks"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getArtworks:
            return .get
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .getArtworks(let artist_id, let exhibition_id):
            var params: [String: Any] = [:]
            if let artist_id = artist_id {
                params["artist_id"] = artist_id
            }
            if let exhibition_id = exhibition_id {
                params["exhibition_id"] = exhibition_id
            }
            return params.isEmpty ? nil : params
        }
    }
    
    var bodyParameters: Codable? {
        switch self {
        case .getArtworks:
            return nil
        }
    }
}


