//
//  BottomButton.swift
//  LastDance
//
//  Created by 신얀 on 10/12/25.
//

import SwiftUI

/// 하단 버튼에 공통으로 사용되는 컴포넌트
struct BottomButton: View {
    let text: String
    let isEnabled: Bool
    let action: () -> Void

    init(text: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.text = text
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(
            action: action,
            label: {
                HStack {
                    Text(text)
                        .foregroundStyle(isEnabled ? LDColor.color6 : LDColor.color1)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 54)
                .background(isEnabled ? LDColor.color1 : LDColor.color6)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isEnabled ? Color.clear : LDColor.gray2, lineWidth: 1)
                )
            }
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 11)
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}
