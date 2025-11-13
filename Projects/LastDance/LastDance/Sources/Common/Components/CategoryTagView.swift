//
//  CategoryTagView.swift
//  LastDance
//
//  Created by donghee on 11/10/25.
//

import SwiftUI

/// 카테고리 태그 UI 컴포넌트
struct CategoryTagView: View {
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .fill(Color.orange)
                .frame(width: 6, height: 6)

            Text(text)
                .font(LDFont.medium06)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(LDColor.color6)
        .cornerRadius(42)
        .shadow(color: .black.opacity(0.24), radius: 0.5, x: 0, y: 0)
    }
}
