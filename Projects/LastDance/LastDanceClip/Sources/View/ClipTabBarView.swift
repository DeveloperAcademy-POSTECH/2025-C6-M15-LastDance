//
//  ClipTabBarView.swift
//  LastDance
//
//  Created by 배현진 on 11/21/25.
//

import SwiftUI

struct ClipTabBarView: View {
    @Binding var selectedTab: ArtReactionTab

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                selectedTab = .artwork
            }) {
                VStack(spacing: 8) {
                    Text("작품")
                        .font(Font.custom("Pretendard", size: 18).weight(.semibold))
                        .foregroundColor(selectedTab == .artwork ? Color(red: 0.14, green: 0.14, blue: 0.14) : Color(red: 0.56, green: 0.56, blue: 0.56))

                    Rectangle()
                        .fill(selectedTab == .artwork ? Color(red: 0.14, green: 0.14, blue: 0.14) : Color(red: 0.97, green: 0.97, blue: 0.97))
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
                        .foregroundColor(selectedTab == .reaction ? Color(red: 0.14, green: 0.14, blue: 0.14) : Color(red: 0.56, green: 0.56, blue: 0.56))

                    Rectangle()
                        .fill(selectedTab == .reaction ? Color(red: 0.14, green: 0.14, blue: 0.14) : Color(red: 0.97, green: 0.97, blue: 0.97))
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
}
