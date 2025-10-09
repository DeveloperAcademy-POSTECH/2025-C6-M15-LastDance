//
//  Artist.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class Artist {
    @Attribute(.unique) var id: String
    var name: String
    var exhibitions: [String] = []          // 전시 ID 목록
    var receivedReactions: [Reaction] = []  // 관계형 데이터

    init(id: String,
         name: String,
         exhibitions: [String] = [],
         receivedReactions: [Reaction] = []) {
        self.id = id
        self.name = name
        self.exhibitions = exhibitions
        self.receivedReactions = receivedReactions
    }
}
