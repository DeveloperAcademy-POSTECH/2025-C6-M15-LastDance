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

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(Font.custom("SF Pro", size: 24))
                .foregroundStyle(.white)
                .frame(width: 71, height: 71)
                .background(
                    Circle()
                        .fill(Color.black)
                )
        }
    }
}
