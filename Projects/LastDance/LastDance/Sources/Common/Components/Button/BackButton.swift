//
//  BackButton.swift
//  LastDance
//
//  Created by donghee on 10/15/25.
//

import SwiftUI

/// 뒤로가기 버튼 컴포넌트
struct BackButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image("chevron.left")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24, height: 24)
    }
  }
}

struct BackWhiteButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image("chevron.left.white")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24, height: 24)
    }
  }
}
