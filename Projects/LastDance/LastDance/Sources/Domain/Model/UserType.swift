//
//  UserType.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import Foundation

/// 사용자 정체성 타입
enum UserType: String, Codable, CaseIterable {
  case artist = "작가"
  case viewer = "관람객"

  var displayName: String {
    return self.rawValue
  }
}
