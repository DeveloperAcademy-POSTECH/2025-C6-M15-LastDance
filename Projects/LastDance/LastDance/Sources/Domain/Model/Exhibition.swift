//
//  Exhibition.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class Exhibition {
    @Attribute(.unique) var id: String
    var title: String
    var descriptionText: String?
    var startDate: String
    var endDate: String
    var artworks: [Artwork] = []
    var venueId: Int?
    var coverImageName: String?
    var createdAt: String?
    var updatedAt: String?

    init(id: String,
         title: String,
         descriptionText: String? = nil,
         startDate: String,
         endDate: String,
         venueId: Int? = nil,
         coverImageName: String? = nil,
         createdAt: String? = nil,
         updatedAt: String? = nil) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.startDate = startDate
        self.endDate = endDate
        self.venueId = venueId
        self.coverImageName = coverImageName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
