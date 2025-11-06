//
//  ArticleButtons.swift
//  LastDance
//
//  Created by donghee on 10/21/25.
//

import SwiftUI

/// 전시 액션 버튼들 (다른 전시 찾기 + 관람 시작하기)
struct ArticleButtons: View {
    let onSearchMore: () -> Void
    let onStartVisit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // 다른 전시 찾기 버튼
            Button(action: onSearchMore) {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.gray5)

                    Text("다른 전시 찾기")
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.gray5)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(LDColor.color5)
                .cornerRadius(12)
            }

            // 관람 시작하기 버튼
            Button(action: onStartVisit) {
                HStack(alignment: .center, spacing: 8) {
                    Text("관람 시작하기")
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.color6)

                    Image(systemName: "arrow.right")
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.color6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(LDColor.black1)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - ArtistConfirmationButtons

/// 작가용 전시 확인 버튼들 (전시중 표시 + 내 전시가 맞아요)
struct ArtistConfirmationButtons: View {
    let onConfirm: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // 전시중 표시
            HStack{
                Image(systemName: "staroflife.fill")
                    .font(LDFont.regular02)
                    .foregroundColor(LDColor.gray5)

                Text("전시중")
                    .font(LDFont.regular02)
                    .foregroundColor(LDColor.gray5)
            }
            .padding(.bottom, 16)
        Spacer()
            // 내 전시가 맞아요 버튼
            Button(action: onConfirm) {
                HStack(alignment: .center, spacing: 8) {
                    Text("내 전시가 맞아요")
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.color6)

                    Image(systemName: "arrow.right")
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.color6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: 160)
                .background(LDColor.color1)
                .cornerRadius(12)
            }
        }
    }
}
