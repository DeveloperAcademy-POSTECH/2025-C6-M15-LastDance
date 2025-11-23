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

@Model
final class Reaction {
    var id: String
    var artworkId: Int
    var visitorId: Int
    var tags: [ReactionTagInfo]?
    var comment: String?
    var createdAt: String?
    var exhibitionId: Int?

    init(
        id: String, artworkId: Int, visitorId: Int, tags: [ReactionTagInfo]? = nil,
        comment: String? = nil, createdAt: String? = nil, exhibitionId: Int? = nil
    ) {
        self.id = id
        self.artworkId = artworkId
        self.visitorId = visitorId
        self.tags = tags
        self.comment = comment
        self.createdAt = createdAt
        self.exhibitionId = exhibitionId
    }
}
