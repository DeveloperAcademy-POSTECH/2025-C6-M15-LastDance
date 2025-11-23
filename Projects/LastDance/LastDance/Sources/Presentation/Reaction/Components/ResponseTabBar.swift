//
//  ResponseTabBar.swift
//  LastDance
//
//  Created by donghee on 11/21/25.
//

import SwiftUI

/// 작품 반응 탭 바 (작품/메시지)
struct ResponseTabBar: View {
    @Binding var selectedTab: ArtworkReactionTab

    var body: some View {
        HStack(spacing: 18) {
            Button(action: {
                selectedTab = .artwork
            }) {
                Text("작품")
                    .font(LDFont.heading03)
                    .foregroundColor(selectedTab == .artwork ? LDColor.color1 : LDColor.color2)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                selectedTab = .message
            }) {
                Text("메시지")
                    .font(LDFont.heading03)
                    .foregroundColor(selectedTab == .message ? LDColor.color1 : LDColor.color2)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
