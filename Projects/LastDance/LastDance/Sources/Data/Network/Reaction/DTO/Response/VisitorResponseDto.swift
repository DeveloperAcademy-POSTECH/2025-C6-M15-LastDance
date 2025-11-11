//
//  VisitorResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

struct VisitorResponseDto: Codable {
  let id: Int
  let uuid: String
  let name: String?
  let created_at: String
  let updated_at: String?
}
