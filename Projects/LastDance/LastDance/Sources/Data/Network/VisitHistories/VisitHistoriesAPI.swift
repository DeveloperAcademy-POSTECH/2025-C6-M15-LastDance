//
//  VisitHistoriesAPI.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

import Moya

enum VisitHistoriesAPI {
    case makeVisitHistories(dto: MakeVisitHistoriesRequestDto)
    case getVisitHistories(visitorId: Int, exhibitionId: Int)
    case getVisitHistory(visitId: Int)
}

extension VisitHistoriesAPI: BaseTargetType {
    var path: String {
        switch self {
        case .makeVisitHistories, .getVisitHistories:
            return "\(APIVersion.version1)/visit-histories"
        case .getVisitHistory(let visitId):
            return "\(APIVersion.version1)/visit-histories/{visit_id}"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .makeVisitHistories:
            return .post
        case .getVisitHistories, .getVisitHistory:
            return .get
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .getVisitHistories(let visitorId, let exhibitionId):
            return [
                "visitor_id": visitorId,
                "exhibition_id": exhibitionId
            ]
        case .makeVisitHistories, .getVisitHistory:
            return nil
        }
    }
    
    var bodyParameters: (any Codable)? {
        switch self {
        case .makeVisitHistories(let dto):
            return dto
        case .getVisitHistories, .getVisitHistory:
            return nil
        }
    }
}

