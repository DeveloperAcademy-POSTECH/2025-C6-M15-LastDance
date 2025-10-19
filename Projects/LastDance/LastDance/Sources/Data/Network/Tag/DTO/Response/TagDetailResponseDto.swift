//
//  TagDetailResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

struct TagDetailResponseDto: Codable {
    let id: Int
    let name: String
    let category_id: Int
    let color_hex: String?
}
