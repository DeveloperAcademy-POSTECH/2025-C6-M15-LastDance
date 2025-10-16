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
    var isMultipart: Bool { get }
    var multipartData: [Moya.MultipartFormData]? { get }  //파일 업로드를 위한 속성
}

extension BaseTargetType {
    var baseURL: URL {
        guard let baseURL = URL(string: Config.baseURL) else {
            fatalError("⚠️ Base URL이 없어요!")
        }
        return baseURL
    }

    var headers: [String: String]? {
        if isMultipart {
            return nil
        }
        return ["Content-Type": "application/json"]
    }

    // 파일 업로드가 없는 요청의 경우 기본값 설정
    var isMultipart: Bool {
        return false
    }

    // 파일 업로드 데이터가 없는 경우 기본값 설정
    var multipartData: [Moya.MultipartFormData]? {
        return nil
    }

    var task: Task {
        if isMultipart, let data = multipartData, !data.isEmpty {
            return .uploadMultipart(data)
        }

        // Query + Body 둘 다 있는 경우
        if let query = queryParameters, let body = bodyParameters {
            return .requestCompositeData(
                bodyData: (try? JSONEncoder().encode(body)) ?? Data(),
                urlParameters: query
            )
        }

        // Query만 있는 경우
        if let query = queryParameters {
            return .requestParameters(
                parameters: query,
                encoding: URLEncoding.queryString
            )
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
