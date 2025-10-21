//
//  CircleSelectionButton.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

/// 원형 선택 버튼 컴포넌트
struct CircleSelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LDFont.medium01)
                .foregroundStyle(isSelected ? .white : .gray)
                .frame(width: 200, height: 200)
                .background(
                    Circle()
                        .fill(isSelected ? Color.black : Color(red: 0.93, green: 0.93, blue: 0.93))
                )
        }
    }
}
