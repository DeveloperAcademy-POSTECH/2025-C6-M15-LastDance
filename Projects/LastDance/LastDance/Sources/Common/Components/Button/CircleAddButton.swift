//
//  CircleAddButton.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

/// 원형 추가 버튼 컴포넌트
struct CircleAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(LDColor.color6)
                .frame(width: 71, height: 71)
                .background(
                    Circle()
                        .fill(LDColor.color1)
                )
        }
    }
}
