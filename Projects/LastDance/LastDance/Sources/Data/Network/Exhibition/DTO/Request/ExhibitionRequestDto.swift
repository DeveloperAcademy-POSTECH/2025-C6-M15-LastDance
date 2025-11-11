//
//  ExhibitionRequestDto.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation

struct ExhibitionRequestDto: Codable {
  let title: String
  let description_text: String?
  let start_date: String
  let end_date: String?
  let venue_id: Int
  let cover_image_url: String?
  let artwork_ids: [Int]?
}
