//
//  ArtistExhibitionDisplayItem.swift
//  LastDance
//
//  Created by 배현진 on 10/21/25.
//

import Foundation
import SwiftData

struct ArtistExhibitionDisplayItem: Identifiable {
  let id: Int  // Exhibition ID
  let exhibition: Exhibition
  var reactionCount: Int
}
