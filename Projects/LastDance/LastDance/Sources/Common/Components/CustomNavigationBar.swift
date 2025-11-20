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

struct CustomNavigationBarWithAction: ToolbarContent {
    let title: String
    let actionTitle: String
    let isActionEnabled: Bool
    let onBackButtonTap: () -> Void
    let onActionTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            BackButton(action: onBackButtonTap)
        }

        ToolbarItem(placement: .principal) {
            Text(title)
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: onActionTap) {
                Text(actionTitle)
                    .font(LDFont.medium04)
                    .foregroundColor(isActionEnabled ? LDColor.color1 : LDColor.color3)
            }
            .disabled(!isActionEnabled)
        }
    }
}

#Preview {
    NavigationStack {
        Text("컨텐츠 영역")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CustomWhiteNavigationBar(title: "전시정보") {
                    print("Back button tapped")
                }
            }
            .preferredColorScheme(.dark)
    }
}
