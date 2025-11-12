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
    var tags: [ReactionTagInfo]
    var comment: String?
    var createdAt: String?

    init(
        id: String,
        artworkId: Int,
        visitorId: Int,
        tags: [ReactionTagInfo],
        comment: String? = nil,
        createdAt: String?
    ) {
        self.id = id
        self.artworkId = artworkId
        self.visitorId = visitorId
        self.tags = tags
        self.comment = comment
        self.createdAt = createdAt
    }
}
