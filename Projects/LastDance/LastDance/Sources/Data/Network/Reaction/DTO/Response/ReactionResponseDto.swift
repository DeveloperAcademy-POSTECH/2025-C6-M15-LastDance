//
//  ReactionResponseDto.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation

// MARK: ReactionResponseDto
struct ReactionResponseDto: Codable {
    let code: Int
    let data: ReactionDetail
}

// MARK: ReactionDetail
struct ReactionDetail: Codable {
    let id: Int
    let artwork_id: Int
    let visitor_id: Int
    let visit_id: Int?
    let comment: String?
    let image_url: String?
    let created_at: String
    let updated_at: String?
    let artwork: ArtworkDetail
    let visitor: VisitorDetail
    let tags: [TagDetail]
}

// MARK: ArtworkDetail
struct ArtworkDetail: Codable {
    let id: Int
    let title: String
    let artist_id: Int
    let description: String?
    let year: Int?
    let thumbnail_url: String?
    let created_at: String
    let updated_at: String?
}

// MARK: VisitorDetail
struct VisitorDetail: Codable {
    let id: Int
    let uuid: String
    let name: String?
    let created_at: String
    let updated_at: String?
}

// MARK: TagDetail
struct TagDetail: Codable {
    let id: Int
    let name: String
    let category_id: Int
    let color_hex: String?
}
