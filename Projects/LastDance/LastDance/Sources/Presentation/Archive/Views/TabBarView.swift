//
//  TabBarView.swift
//  LastDance
//
//  Created by 배현진 on 11/11/25.
//

import SwiftUI

// MARK: - TabBarView Component
struct TabBarView: View {
    @Binding var selectedTab: ArtReactionTab

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                selectedTab = .artwork
            }) {
                VStack(spacing: 8) {
                    Text("작품")
                        .font(Font.custom("Pretendard", size: 18).weight(.semibold))
                        .foregroundColor(selectedTab == .artwork ? LDColor.color1 : LDColor.color2)

                    Rectangle()
                        .fill(selectedTab == .artwork ? LDColor.color1 : LDColor.color5)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)

            Button(action: {
                selectedTab = .reaction
            }) {
                VStack(spacing: 8) {
                    Text("감상")
                        .font(Font.custom("Pretendard", size: 18).weight(.semibold))
                        .foregroundColor(selectedTab == .reaction ? LDColor.color1 : LDColor.color2)

                    Rectangle()
                        .fill(selectedTab == .reaction ? LDColor.color1 : LDColor.color5)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
}
