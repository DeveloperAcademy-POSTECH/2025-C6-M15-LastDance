//
//  ReactionTag.swift
//  LastDance
//
//  Created by 아우신얀 on 10/19/25.
//

import SwiftUI

struct ReactionTag: View {
  let text: String  // 카테고리 태그 제목
  let color: Color  // 카테고리 태그 색상

  var body: some View {
    HStack(spacing: 8) {
      Circle()
        .fill(color)
        .frame(width: 6, height: 6)

      Text(text)
        .foregroundColor(LDColor.black1)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 8)
    .background(
      Capsule()
        .fill(LDColor.color6)
    )
  }
}
