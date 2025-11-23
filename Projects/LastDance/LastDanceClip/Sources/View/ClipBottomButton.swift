//
//  ClipBottomButton.swift
//  LastDance
//
//  Created by 배현진 on 11/21/25.
//

import SwiftUI

struct ClipBottomButton: View {
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
                        .foregroundStyle(isEnabled ? Color.white : Color(red: 0.14, green: 0.14, blue: 0.14))
                        .font(.system(size: 18, weight: .semibold))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 54)
                .background(isEnabled ? Color(red: 0.14, green: 0.14, blue: 0.14) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isEnabled ? Color.clear : Color(red: 0.77, green: 0.77, blue: 0.77), lineWidth: 1)
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
