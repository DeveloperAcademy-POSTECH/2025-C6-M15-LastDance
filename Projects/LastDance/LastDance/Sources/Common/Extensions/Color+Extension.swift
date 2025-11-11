//
//  Color+Extension.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

import SwiftUI

extension Color {
  init(hex: String, alpha: Double = 1) {
    let cleanedHexString = hex.replacingOccurrences(of: "#", with: "")
    var hexValue: UInt64 = 0
    Scanner(string: cleanedHexString).scanHexInt64(&hexValue)
    self.init(
      .sRGB,
      red: Double((hexValue >> 16) & 0xFF) / 255,
      green: Double((hexValue >> 8) & 0xFF) / 255,
      blue: Double(hexValue & 0xFF) / 255,
      opacity: alpha
    )
  }
}
