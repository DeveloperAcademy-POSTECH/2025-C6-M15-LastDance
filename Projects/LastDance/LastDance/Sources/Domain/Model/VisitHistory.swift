//
//  VisitHistory.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

import Foundation
import SwiftData

@Model
final class VisitHistory {
  var id: Int
  var visitorId: Int
  var exhibitionId: Int
  var visitedAt: Date

  init(
    id: Int,
    visitorId: Int,
    exhibitionId: Int,
    visitedAt: Date
  ) {
    self.id = id
    self.visitorId = visitorId
    self.exhibitionId = exhibitionId
    self.visitedAt = visitedAt
  }
}
