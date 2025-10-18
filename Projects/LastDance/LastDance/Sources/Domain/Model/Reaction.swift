//
//  Reaction.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class Reaction {
    var id: String
    var artworkId: Int
    var visitorId: Int
    var category: [String]
    var comment: String?
    var createdAt: Date

    init(id: String,
         artworkId: Int,
         visitorId: Int,
         category: [String],
         comment: String? = nil,
         createdAt: Date = .now) {
        self.id = id
        self.artworkId = artworkId
        self.visitorId = visitorId
        self.category = category
        self.comment = comment
        self.createdAt = createdAt
    }
}
