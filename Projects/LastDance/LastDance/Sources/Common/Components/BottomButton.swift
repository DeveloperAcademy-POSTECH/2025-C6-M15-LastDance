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
    let action: () -> Void
    
    init(text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button(
            action: action,
            label: {
                HStack {
                    Text(text)
                        .foregroundStyle(.black)
                }
            }
        )
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(.black, lineWidth: 1)
        )
    }
}
