//
//  BaseResponse.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation

// TODO: 백엔드 스펙에 맞춰 수정 필요
/// 백엔드 API 공통 응답
struct BaseResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}

/// 데이터가 없는 응답
struct EmptyResponse: Decodable {}
