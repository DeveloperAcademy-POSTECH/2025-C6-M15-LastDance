//
//  Invitation.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import Foundation
import SwiftData

@Model
final class Invitation {
    @Attribute(.unique) var id: Int
    var exhibitionId: Int
    var exhibitionTitle: String
    var artistName: String
    var venueName: String
    var venueAddress: String
    var startDate: String
    var endDate: String
    var coverImageName: String?
    var invitationMessage: String
    var visitorCount: Int
    var createdAt: String?
    var deepLink: String?
    var appStoreLink: String?

    init(
        id: Int,
        exhibitionId: Int,
        exhibitionTitle: String,
        artistName: String,
        venueName: String,
        venueAddress: String,
        startDate: String,
        endDate: String,
        coverImageName: String? = nil,
        invitationMessage: String,
        visitorCount: Int = 0,
        createdAt: String? = nil,
        deepLink: String? = nil,
        appStoreLink: String? = nil
    ) {
        self.id = id
        self.exhibitionId = exhibitionId
        self.exhibitionTitle = exhibitionTitle
        self.artistName = artistName
        self.venueName = venueName
        self.venueAddress = venueAddress
        self.startDate = startDate
        self.endDate = endDate
        self.coverImageName = coverImageName
        self.invitationMessage = invitationMessage
        self.visitorCount = visitorCount
        self.createdAt = createdAt
        self.deepLink = deepLink
        self.appStoreLink = appStoreLink
    }
}
