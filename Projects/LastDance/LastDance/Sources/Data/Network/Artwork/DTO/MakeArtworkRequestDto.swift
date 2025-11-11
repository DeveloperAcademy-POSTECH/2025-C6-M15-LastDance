//
//  MakeArtworkRequestDto.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation

struct MakeArtworkRequestDto: Codable {
  let title: String
  let artist_id: Int
  let description: String?
  let year: Int?
  let thumbnail_url: String?
}
