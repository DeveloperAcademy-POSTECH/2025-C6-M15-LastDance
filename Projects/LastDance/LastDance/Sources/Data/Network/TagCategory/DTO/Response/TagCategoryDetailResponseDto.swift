//
//  TagCategoryDetailResponseDto.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

struct TagCategoryDetailResponseDto: Codable {
    let id: Int
    let name: String
    let color_hex: String
    let created_at: String
    let updated_at: String?
    let tags: [TagDetailResponseDto]
}
