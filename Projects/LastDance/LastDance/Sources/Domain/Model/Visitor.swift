//
//  User.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class Visitor {
  var id: Int
  var uuid: String
  var name: String?
  var visitedExhibitions: [Exhibition] = []
  var sentReactions: [Reaction] = []

  init(
    id: Int,
    uuid: String,
    name: String? = nil,
    visitedExhibitions: [Exhibition] = [],
    sentReactions: [Reaction] = []
  ) {
    self.id = id
    self.uuid = uuid
    self.name = name
    self.visitedExhibitions = visitedExhibitions
    self.sentReactions = sentReactions
  }
}
