//
//  ArtworkInfoSection.swift
//  LastDance
//
//  Created by donghee on 11/21/25.
//

import SwiftUI

/// 작품 정보 섹션 (반응 수, 작품 제목, 작품 설명)
struct ArtworkInfoSection: View {
    let artwork: Artwork?
    @ObservedObject var viewModel: ArtworkReactionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 반응 수
            Text("반응 수")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
                .padding(.top, 12)

            Text("\(viewModel.reactions.count)")
                .font(LDFont.heading01)
                .foregroundColor(LDColor.color1)
                .padding(.top, 8)

            // 작품 제목
            Text("작품 제목")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
                .padding(.top, 48)

            Text(artwork?.title ?? "")
                .font(LDFont.heading03)
                .foregroundColor(LDColor.color1)
                .padding(.top, 8)

            // 작품 설명
            Text("작품 설명")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
                .padding(.top, 36)

            if let description = artwork?.descriptionText, !description.isEmpty {
                Text(description)
                    .font(LDFont.medium03)
                    .foregroundColor(LDColor.color2)
                    .lineSpacing(4)
                    .padding(.top, 8)
            } else {
                Text("작품 설명이 없습니다.")
                    .font(LDFont.medium03)
                    .foregroundColor(LDColor.color2)
                    .padding(.top, 8)
            }

            Spacer(minLength: 100)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}
