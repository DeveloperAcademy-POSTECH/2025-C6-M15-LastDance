//
//  ArtistExhibitionPreviewCard.swift
//  LastDance
//
//  Created by donghee on 10/21/25.
//

import SwiftUI
import Foundation

struct ArtistExhibitionPreviewCard: View {
    let exhibition: Exhibition
    let artistNames: [String]
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // 전시 이미지
            ArtistExhibitionPreviewImage(imageName: exhibition.coverImageName)
            // 전시 정보 및 버튼
            ArtistExhibitionPreviewInfo(
                title: exhibition.title,
                artistNames: artistNames,
                dateRange: Date.formatShortDateRange(start: exhibition.startDate, end: exhibition.endDate),
                onConfirm: onConfirm
            )
            .padding(.horizontal, 12)

        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 0)
    }
}

// MARK: - ArtistExhibitionPreviewImage
struct ArtistExhibitionPreviewImage: View {
    let imageName: String?

    var body: some View {
        if let imageName = imageName, let url = URL(string: imageName) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 365, height: 468)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 365, height: 468)
                        .clipped()
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 12,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 12
                            )
                        )
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 365, height: 468)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 12,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 12
                            )
                        )
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("이미지 없음")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            // Fallback if imageName is nil or not a valid URL
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 365, height: 468)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                )
                .overlay(
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("이미지 없음")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                )
        }
    }
}

// MARK: - ArtistExhibitionPreviewInfo

struct ArtistExhibitionPreviewInfo: View {
    let title: String
    let artistNames: [String]
    let dateRange: String
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 전시 정보
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color1)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                if !artistNames.isEmpty {
                    Text(artistNames.joined(separator: ", "))
                        .font(LDFont.regular02)
                        .foregroundColor(LDColor.gray4)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }

                Text(dateRange)
                    .font(LDFont.regular02)
                    .foregroundColor(LDColor.gray4)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .frame(height: 0.5)
                    .foregroundColor(LDColor.gray3)
            }
            .padding(.top, 14)

            // 액션 버튼들
            ArtistConfirmationButtons(
                onConfirm: onConfirm
            )
            .padding(.bottom, 14)
        }
    }
}