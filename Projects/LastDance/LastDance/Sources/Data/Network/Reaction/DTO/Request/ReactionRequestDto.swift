//
//  ReactionRequestDto.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation

struct ReactionRequestDto: Codable {
    let artworkId: Int
    let visitorId: Int
    let visitId: Int
    let comment: String?
    let imageUrl: String?
    let tagIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case artworkId = "artwork_id"
        case visitorId = "visitor_id"
        case visitId = "visit_id"
        case comment
        case imageUrl = "image_url"
        case tagIds = "tag_ids"
    }
}
