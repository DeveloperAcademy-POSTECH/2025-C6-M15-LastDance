//
//  IdentificatedArtwork.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class IdentificatedArtwork {
  var id: String
  var capturedId: String
  var uploadedImagePath: String
  var recognizedArtworkName: String
  var recognizedArtistName: String

  init(
    id: String,
    capturedId: String,
    uploadedImagePath: String,
    recognizedArtworkName: String,
    recognizedArtistName: String
  ) {
    self.id = id
    self.capturedId = capturedId
    self.uploadedImagePath = uploadedImagePath
    self.recognizedArtworkName = recognizedArtworkName
    self.recognizedArtistName = recognizedArtistName
  }
}
