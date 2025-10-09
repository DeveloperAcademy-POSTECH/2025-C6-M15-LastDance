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
    var startDate: Date
    var endDate: Date
    var artworks: [Artwork] = []
    var venueId: String?
    var coverImageName: String?

    init(id: String,
         title: String,
         descriptionText: String? = nil,
         startDate: Date,
         endDate: Date,
         venueId: String? = nil,
         coverImageName: String? = nil) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.startDate = startDate
        self.endDate = endDate
        self.venueId = venueId
        self.coverImageName = coverImageName
    }
}
