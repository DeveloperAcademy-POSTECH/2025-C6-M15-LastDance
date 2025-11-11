//
//  CategoryButton.swift
//  LastDance
//
//  Created by 신얀 on 10/12/25.
//

import SwiftUI

// TODO: 하이파이 완성시 UI 수정 필요
struct CategoryButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category)
                .foregroundColor(isSelected ? .white : .black)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.black : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.black : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
