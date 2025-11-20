//
//  ArtistCode.swift
//  LastDance
//
//  Created by 아우신얀 on 11/17/25.
//

import Foundation
import SwiftData

@Model
final class ArtistCode {
    @Attribute(.unique) var id: Int
    var uuid: String
    var name: String
    var bio: String?
    var email: String?

    init(id: Int, uuid: String, name: String, bio: String? = nil, email: String? = nil) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.bio = bio
        self.email = email
    }
}
