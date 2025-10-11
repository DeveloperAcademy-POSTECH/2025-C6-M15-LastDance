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
    let action: () -> Void
    
    var body: some View {
        Button(
            action: action,
            label: {
                Text(title)
                    .foregroundStyle(.black)
            }
        )
        .padding(.horizontal, 38)
        .padding(.vertical, 11)
        .border(.black)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(
                    Color(.black),
                    lineWidth: 1
                )
        )
    }
}
