//
//  MoreCategoriesButton.swift
//  LastDance
//
//  Created by donghee on 11/10/25.
//

import SwiftUI

/// 더보기 버튼 컴포넌트
struct MoreCategoriesButton: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("+\(count)")
                .font(LDFont.medium06)
                .foregroundColor(LDColor.color1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(LDColor.color6)
                .cornerRadius(42)
                .shadow(color: .black.opacity(0.24), radius: 0.5, x: 0, y: 0)
        }
    }
}
