//
//  Venue.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class Venue {
  @Attribute(.unique) var id: Int
  var name: String
  var address: String?
  var geoLat: Double?
  var geoLon: Double?

  init(
    id: Int,
    name: String,
    address: String? = nil,
    geoLat: Double? = nil,
    geoLon: Double? = nil
  ) {
    self.id = id
    self.name = name
    self.address = address
    self.geoLat = geoLat
    self.geoLon = geoLon
  }
}
