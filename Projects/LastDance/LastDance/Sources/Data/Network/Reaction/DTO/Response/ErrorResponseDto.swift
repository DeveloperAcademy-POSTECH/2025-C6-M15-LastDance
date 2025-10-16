//
//  ErrorResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

import Foundation

// MARK: - ErrorResponseDto
struct ErrorResponseDto: Codable, Error {
    let detail: [ErrorDetail]
}

// MARK: - ErrorDetail
struct ErrorDetail: Codable {
    let msg: String
    let type: String
}
