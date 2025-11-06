//
//  OutlinedButton.swift
//  LastDance
//
//  Created by 신얀 on 10/11/25.
//

import Foundation
import SwiftUI

struct OutlinedButton: View {
    let title: String
    var color: Color
    var textColor: Color
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                Text(title)
                    .foregroundStyle(textColor)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .font(LDFont.heading04)
            }
        )
        .frame(height: 54)
        .background(color)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: 1)
        )
    }
}
