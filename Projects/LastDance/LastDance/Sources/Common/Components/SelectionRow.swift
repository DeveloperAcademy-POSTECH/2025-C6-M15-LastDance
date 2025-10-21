//
//  SelectionRow.swift
//  LastDance
//
//  Created by donghee on 10/16/25.
//

import SwiftUI

/// 선택 가능한 목록 행 컴포넌트
struct SelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(red: 0.96, green: 0.96, blue: 0.96) : LDColor.color6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.9)
                        .stroke(
                            isSelected ? Color(red: 0.14, green: 0.14, blue: 0.14) : Color.black.opacity(0.18),
                            lineWidth: isSelected ? 1.8 : 1
                        )
                )
        }
        .padding(.bottom, 8)
    }
}
