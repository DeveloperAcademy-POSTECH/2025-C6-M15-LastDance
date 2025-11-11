//
//  TagDetailWithCategoryResponseDto.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

struct TagDetailWithCategoryResponseDto: Codable {
  let id: Int
  let name: String
  let category_id: Int
  let color_hex: String
  let category: TagCategoryListResponseDto
}
