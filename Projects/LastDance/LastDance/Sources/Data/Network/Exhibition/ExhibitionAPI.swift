//
//  ExhibitionAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Moya

enum ExhibitionAPI {
    case getExhibitions(status: String?, venue_id: Int?)
    case makeExhibition(dto: ExhibitionRequestDto)
}

extension ExhibitionAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getExhibitions, .makeExhibition:
            return "\(APIVersion.version1)/exhibitions"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getExhibitions:
            return .get
        case .makeExhibition:
            return .post
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .getExhibitions(let status, let venue_id):
            var params: [String: Any] = [:]
            if let status = status {
                params["status"] = status
            }
            if let venue_id = venue_id {
                params["venue_id"] = venue_id
            }
            return params.isEmpty ? nil : params
        case .makeExhibition:
            return nil
        }
    }
    
    var bodyParameters: Codable? {
        switch self {
        case .getExhibitions:
            return nil
        case .makeExhibition(let dto):
            return dto
        }
    }
}

