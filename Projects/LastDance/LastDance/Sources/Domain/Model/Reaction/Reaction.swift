//
//  Reaction.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

struct ReactionTagInfo: Codable, Hashable {
    let name: String
    let colorHex: String
}

struct ArtistMessageInfo: Codable, Hashable {
    let id: Int
    let artistName: String
    let message: String
    let createdAt: String
}

@Model
final class Reaction {
    var id: String
    var artworkId: Int
    var visitorId: Int
    var tags: [ReactionTagInfo]?
    var comment: String?
    var artistEmoji: String?
    var artistMessages: [ArtistMessageInfo]?
    var createdAt: String?

    init(
        id: String, artworkId: Int, visitorId: Int, tags: [ReactionTagInfo]? = nil,
        comment: String? = nil, artistEmoji: String? = nil, artistMessages: [ArtistMessageInfo]? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.artworkId = artworkId
        self.visitorId = visitorId
        self.tags = tags
        self.comment = comment
        self.artistEmoji = artistEmoji
        self.artistMessages = artistMessages
        self.createdAt = createdAt
    }
}
