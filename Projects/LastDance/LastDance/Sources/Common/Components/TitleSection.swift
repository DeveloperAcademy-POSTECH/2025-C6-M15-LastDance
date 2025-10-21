//
//  TitleSection.swift
//  LastDance
//
//  Created by donghee on 10/16/25.
//

import SwiftUI

/// 화면 상단 타이틀 섹션 컴포넌트
struct TitleSection: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(LDFont.heading02)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(LDFont.regular02)
                    .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.52))
                    .padding(.top, 24)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
}
