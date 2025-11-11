//
//  ArtworkDetailResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

// MARK: ArtworkDetail
struct ArtworkDetailResponseDto: Codable {
  let id: Int
  let title: String
  let artist_id: Int
  let description: String?
  let year: Int?
  let thumbnail_url: String?
  let created_at: String
  let updated_at: String?
}
