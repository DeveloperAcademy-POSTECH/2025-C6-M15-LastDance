//
//  EmojiReactionResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 11/19/25.
//

// MARK: EmojiReactionResponseDto
struct EmojiReactionResponseDto: Codable {
    let id: Int
    let artist_id: Int
    let artist: ArtistDetail?
    let reaction_id: Int
    let emoji_type: String
    let created_at: String

    struct ArtistDetail: Codable {
        let id: Int
        let name: String
    }
}
