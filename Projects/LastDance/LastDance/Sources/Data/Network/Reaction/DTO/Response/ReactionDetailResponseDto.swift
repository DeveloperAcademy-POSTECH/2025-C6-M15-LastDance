//
//  ReactionDetailResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

// MARK: ReactionDetailResponseDto

struct ReactionDetailResponseDto: Codable {
    let id: Int
    let artwork_id: Int
    let artwork: ArtworkDetailResponseDto
    let visitor_id: Int
    let visitor: VisitorResponseDto
    let visit_id: Int?
    let visit: VisitDetail?
    let comment: String?
    let image_url: String?
    let tags: [TagDetailResponseDto]?
    let artist_emojis: [ArtistEmojiDto]?
    let artist_messages: [ArtistMessageDto]?
    let created_at: String
    let updated_at: String?
    let visitor_name: String?
    let artwork_title: String?

    struct VisitDetail: Codable {
        let id: Int
        let exhibition_id: Int
        let exhibition_title: String
        let visited_at: String
    }

    struct ArtistEmojiDto: Codable {
        let id: Int
        let artist_id: Int
        let emoji_type: String
        let created_at: String
    }

    struct ArtistMessageDto: Codable {
        let id: Int
        let artist_id: Int
        let message: String
        let created_at: String
    }
}
