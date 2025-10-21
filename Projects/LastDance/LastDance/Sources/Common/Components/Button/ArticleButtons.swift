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
                        .font(Font.custom("Pretendard", size: 17).weight(.semibold))
                        .foregroundColor(Color(red: 0.14, green: 0.14, blue: 0.14))

                    Text("다른 전시 찾기")
                        .font(Font.custom("Pretendard", size: 17).weight(.semibold))
                        .foregroundColor(Color(red: 0.14, green: 0.14, blue: 0.14))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                .cornerRadius(12)
            }

            // 관람 시작하기 버튼
            Button(action: onStartVisit) {
                HStack(alignment: .center, spacing: 8) {
                    Text("관람 시작하기")
                        .font(Font.custom("Pretendard", size: 17).weight(.semibold))
                        .foregroundColor(.white)

                    Image(systemName: "arrow.right")
                        .font(Font.custom("Pretendard", size: 17).weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.14, green: 0.14, blue: 0.14))
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
                    .font(Font.custom("Pretendard", size: 17).weight(.semibold))
                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                
                Text("전시중")
                    .font(Font.custom("Pretendard", size: 17).weight(.semibold))
                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
            }
            .padding(.bottom, 16)
        Spacer()
            // 내 전시가 맞아요 버튼
            Button(action: onConfirm) {
                HStack(alignment: .center, spacing: 8) {
                    Text("내 전시가 맞아요")
                        .font(Font.custom("Pretendard", size: 17).weight(.semibold))
                        .foregroundColor(.white)

                    Image(systemName: "arrow.right")
                        .font(Font.custom("Pretendard", size: 17).weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: 160)
                .background(Color(red: 0.14, green: 0.14, blue: 0.14))
                .cornerRadius(12)
            }
        }
    }
}
