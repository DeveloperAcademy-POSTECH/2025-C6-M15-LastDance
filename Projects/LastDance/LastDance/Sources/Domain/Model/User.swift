//
//  User.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var role: String
    var visitedExhibitions: [Exhibition] = []
    var sentReactions: [Reaction] = []

    init(id: UUID = UUID(),
         role: String,
         visitedExhibitions: [Exhibition] = [],
         sentReactions: [Reaction] = []) {
        self.id = id
        self.role = role
        self.visitedExhibitions = visitedExhibitions
        self.sentReactions = sentReactions
    }
}
