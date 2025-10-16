//
//  ExhibitionAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Moya

enum ExhibitionStatus: String {
    case ongoing = "ongoing"
    case upcoming = "upcoming"
    case past = "past"
}

enum ExhibitionAPI {
    case getExhibitions(status: String?, venue_id: Int?)
}

extension ExhibitionAPI: BaseTargetType {
    var path: String {
        switch self {
            // TODO: 리액션 api 연동 머지 되면 수정할 예정
        case .getExhibitions:
            return "/api/v1/exhibitions"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getExhibitions:
            return .get
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
        }
    }
    
    var bodyParameters: Codable? {
        switch self {
        case .getExhibitions:
            return nil
        }
    }
}

