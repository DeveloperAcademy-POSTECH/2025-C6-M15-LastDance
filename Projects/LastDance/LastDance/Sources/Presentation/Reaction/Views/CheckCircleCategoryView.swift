//
//  Untitled.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

import SwiftUI

/// 체크버튼 + 카테고리 명칭 함께 표시하는 뷰
struct CheckCircleCategoryView: View {
  let isSelected: Bool
  let category: TagCategory

  var body: some View {
    HStack {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 20))
        .foregroundStyle(isSelected ? category.color : Color(red: 0.73, green: 0.73, blue: 0.73))
        .padding(.trailing, 8)

      Text(category.name)
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(.black)

      Spacer()
    }
  }
}
