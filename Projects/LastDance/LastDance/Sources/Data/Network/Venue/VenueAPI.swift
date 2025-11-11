//
//  VenueAPI.swift
//  LastDance
//
//  Created by 배현진 on 10/18/25.
//

import Moya

enum VenueAPI {
    case getVenues
    case getVenue(id: Int)
}

extension VenueAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getVenues:
            return "\(APIVersion.version1)/venues"
        case let .getVenue(id):
            return "\(APIVersion.version1)/venues/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getVenues, .getVenue:
            return .get
        }
    }

    var queryParameters: [String: Any]? {
        return nil
    }

    var bodyParameters: Codable? {
        return nil
    }
}
