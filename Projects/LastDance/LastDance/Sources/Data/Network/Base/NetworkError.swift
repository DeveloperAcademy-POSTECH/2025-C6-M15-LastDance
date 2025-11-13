//
//  NetworkError.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation

// TODO: 백엔드 기능 명세에 따라 수정될 수 있음
enum NetworkError: Error {
    case badRequest
    case notFound
    case decodingFailed
    case networkFailure
    case serverError  // 보통 500번대

    var message: String {
        switch self {
        case .badRequest:
            return NetworkErrorMessages.badRequest
        case .notFound:
            return NetworkErrorMessages.notFound
        case .decodingFailed:
            return NetworkErrorMessages.decodingFailed
        case .networkFailure:
            return NetworkErrorMessages.networkFailure
        case .serverError:
            return NetworkErrorMessages.serverError
        }
    }
}
