//
//  ArtistDetailResponseDto.swift
//  LastDance
//
//  Created by 배현진 on 10/18/25.
//

struct ArtistDetailResponseDto: Codable {
  let id: Int
  let uuid: String
  let name: String
  let bio: String?
  let email: String?
  let created_at: String
  let updated_at: String?
}
