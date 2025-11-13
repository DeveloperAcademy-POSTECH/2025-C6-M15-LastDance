//
//  CustomNavigationBar.swift
//  LastDance
//
//  Created by donghee on 10/15/25.
//

import SwiftUI

/// 커스텀 네비게이션 바 컴포넌트
struct CustomNavigationBar: ToolbarContent {
    let title: String
    let onBackButtonTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            BackButton(action: onBackButtonTap)
        }

        ToolbarItem(placement: .principal) {
            Text(title)
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
        }
    }
}

struct CustomWhiteNavigationBar: ToolbarContent {
    let title: String
    let onBackButtonTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            BackWhiteButton(action: onBackButtonTap)
        }

        ToolbarItem(placement: .principal) {
            Text(title)
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color6)
        }
    }
}

struct CustomXmarkNavigationBar: ToolbarContent {
    let title: String
    let onXmarkButtonTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            XmarkButton(action: onXmarkButtonTap)
        }

        ToolbarItem(placement: .principal) {
            Text(title)
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
        }
    }
}

#Preview {
    NavigationStack {
        Text("컨텐츠 영역")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CustomNavigationBar(title: "전시정보") {
                    print("Back button tapped")
                }
            }
    }
}
