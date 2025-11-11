//
//  CapturedArtwork.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class CapturedArtwork {
  var id: Int
  var artworkId: Int?
  var localImagePath: String
  var createdAt: Date
  var note: String?

  init(
    id: Int,
    artworkId: Int? = nil,
    localImagePath: String,
    createdAt: Date = .now,
    note: String? = nil
  ) {
    self.id = id
    self.artworkId = artworkId
    self.localImagePath = localImagePath
    self.createdAt = createdAt
    self.note = note
  }
}
