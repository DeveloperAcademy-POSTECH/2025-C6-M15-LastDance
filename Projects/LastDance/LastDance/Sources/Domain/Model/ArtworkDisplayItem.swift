//
//  ArtworkDisplayItem.swift
//  LastDance
//
//  Created by 배현진 on 10/21/25.
//

import Foundation
import SwiftData

struct ArtworkDisplayItem: Identifiable {
  let id: Int  // Artwork ID
  let artwork: Artwork
  var reactionCount: Int
}
