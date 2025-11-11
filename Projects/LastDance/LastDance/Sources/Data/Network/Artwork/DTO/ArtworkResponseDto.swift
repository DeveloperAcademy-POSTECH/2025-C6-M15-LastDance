//
//  ArtworkResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/18/25.
//

import Foundation

struct ArtworkResponseDto: Codable {
  let id: Int
  let title: String
  let artist_id: Int
  let description: String?
  let year: Int?
  let thumbnail_url: String?
  let created_at: String
  let updated_at: String?
  let artist: MakeArtworkDetail
  let exhibitions: [MakeExhibitionDetail]?

  struct MakeArtworkDetail: Codable {
    let id: Int
    let uuid: String
    let name: String
    let bio: String?
    let email: String?
    let created_at: String?
    let updated_at: String?
  }

  // TODO: PR 병합 후 중복 응답 dto 수정 예정
  struct MakeExhibitionDetail: Codable {
    let id: Int
    let title: String
    let description_text: String?
    let start_date: String
    let end_date: String
    let venue_id: Int
    let cover_image_url: String?
    let created_at: String
    let updated_at: String?
  }
}
