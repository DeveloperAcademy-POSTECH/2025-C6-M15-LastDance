//
//  ShutterButton.swift
//  LastDance
//
//  Created by 배현진 on 10/10/25.
//

import SwiftUI

/// 하단 셔터 버튼
struct ShutterButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(LDColor.color6)
                    .frame(width: 60, height: 60)
                Circle()
                    .stroke(LDColor.color6.opacity(0.6), lineWidth: 2)
                    .frame(width: 72, height: 72)
            }
        }
    }
}
