//
//  TagDetailResponseDto.swift
//  LastDance
//
//  Created by 배현진 on 11/17/25.
//

struct TagDetailResponseDto: Codable {
    let id: Int
    let name: String
    let category: TagCategoryListResponseDto
    let color_hex: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case color_hex
    }
}
