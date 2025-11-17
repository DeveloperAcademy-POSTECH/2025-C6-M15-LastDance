//
//  ArtistAPI.swift
//  LastDance
//
//  Created by 배현진, 신얀 on 10/18/25.
//

import Moya

enum ArtistAPI {
    case getArtists
    case createArtist(dto: ArtistCreateRequestDto)
    case getArtist(id: Int)
    case getArtistByUUID(uuid: String)
    case artistLogin(dto: ArtistCodeRequestDto)
}

extension ArtistAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getArtists, .createArtist:
            return "\(APIVersion.version1)/artists"
        case .getArtist(let id):
            return "\(APIVersion.version1)/artists/\(id)"
        case .getArtistByUUID(let uuid):
            return "\(APIVersion.version1)/artists/uuid/\(uuid)"
        case .artistLogin:
            return "\(APIVersion.version1)/artists/login"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getArtists, .getArtist, .getArtistByUUID:
            return .get
        case .createArtist, .artistLogin:
            return .post
        }
    }

    var queryParameters: [String: Any]? { nil }

    var bodyParameters: Codable? {
        switch self {
        case .createArtist(let dto):
            return dto
        case .artistLogin(let dto):
            return dto
        default:
            return nil
        }
    }
}
