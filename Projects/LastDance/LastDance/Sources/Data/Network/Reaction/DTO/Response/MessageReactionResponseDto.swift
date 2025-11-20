//
//  MessageReactionResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 11/19/25.
//

import Foundation

struct MessageReactionResponseDto: Codable {
    let id: Int
    let artist_id: Int
    let artist: ArtistDetail
    let reaction_id: Int
    let message: String
    let created_at: String

    struct ArtistDetail: Codable {
        let id: Int
        let uuid: String
        let name: String
    }
}
