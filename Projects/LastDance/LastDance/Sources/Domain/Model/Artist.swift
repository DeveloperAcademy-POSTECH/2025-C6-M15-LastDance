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
    @Attribute(.unique) var id: Int
    var uuid: String
    var name: String
    var exhibitions: [Int] = [] // 전시 ID 목록
    var receivedReactions: [Reaction] = [] // 관계형 데이터

    init(
        id: Int,
        uuid: String,
        name: String,
        exhibitions: [Int] = [],
        receivedReactions: [Reaction] = []
    ) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.exhibitions = exhibitions
        self.receivedReactions = receivedReactions
    }
}
