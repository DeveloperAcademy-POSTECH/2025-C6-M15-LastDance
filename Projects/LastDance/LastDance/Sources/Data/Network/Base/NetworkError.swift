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
    case serverError // 보통 500번대
    
    var message: String {
        switch self {
        case .badRequest:
            return "잘못된 요청입니다."
        case .notFound:
            return "요청한 데이터를 찾을 수 없습니다."
        case .decodingFailed:
            return "데이터를 파싱에 실패했습니다."
        case .networkFailure:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 에러가 발생했습니다."
        }
    }
}


