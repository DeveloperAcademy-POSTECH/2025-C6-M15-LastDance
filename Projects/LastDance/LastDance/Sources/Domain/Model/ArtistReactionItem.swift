//
//  ArtistReactionItem.swift
//  LastDance
//
//  Created by 광로 on 10/16/25.
//

import SwiftUI

struct ReactionItem: Identifiable {
    let id = UUID()
    let imageName: String
    let reactionCount: Int
    let category: String
}
