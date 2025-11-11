//
//  VisitorListResponseDto.swift
//  LastDance
//
//  Created by 배현진 on 10/17/25.
//

struct VisitorListResponseDto: Codable {
    let id: Int
    let uuid: String
    let name: String?
    let created_at: String
    let updated_at: String?
}
