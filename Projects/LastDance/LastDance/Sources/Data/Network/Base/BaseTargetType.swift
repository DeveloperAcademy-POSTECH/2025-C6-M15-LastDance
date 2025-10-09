//
//  BaseTargetType.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType {
    var queryParameters: [String: Any]? { get }
    var bodyParameters: Codable? { get }
}


extension BaseTargetType {
    var baseURL: URL {
        // TODO: 백엔드 서버 주소 반영 및 config 파일로 관리
        return URL(string: "")!
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var task: Task {
        // Query + Body 둘 다 있는 경우
        if let query = queryParameters, let body = bodyParameters {
            return .requestCompositeParameters(
                bodyParameters: [:],
                bodyEncoding: JSONEncoding.default,
                urlParameters: query
            )
        }
        
        // Query만 있는 경우
        if let query = queryParameters {
            return .requestParameters(parameters: query, encoding: URLEncoding.queryString)
        }
        
        // Body만 있는 경우
        if let body = bodyParameters {
            return .requestJSONEncodable(body)
        }
        
        // 둘 다 없는 경우
        return .requestPlain
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    var simpleData: Data {
        return Data()
    }
}
