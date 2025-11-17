//
//  ExhibitionPreviewCard.swift
//  LastDance
//
//  Created by donghee on 10/20/25.
//

import Foundation
import SwiftUI

struct ExhibitionPreviewCard: View {
    let exhibition: Exhibition
    let artistNames: [String]
    let onSearchMore: () -> Void
    let onStartVisit: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // 전시 이미지
            ExhibitionPreviewImage(imageName: exhibition.coverImageName)
            // 전시 정보 및 버튼
            ExhibitionPreviewInfo(
                title: exhibition.title,
                artistNames: artistNames,
                dateRange: Date.formatShortDateRange(
                    start: exhibition.startDate, end: exhibition.endDate),
                onSearchMore: onSearchMore,
                onStartVisit: onStartVisit
            )
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 0)
    }
}

// MARK: - ExhibitionPreviewImage

struct ExhibitionPreviewImage: View {
    let imageName: String?

    var body: some View {
        CachedImage(imageName, targetSize: CGSize(width: 365, height: 468))
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
    }
}

// MARK: - ExhibitionPreviewInfo

struct ExhibitionPreviewInfo: View {
    let title: String
    let artistNames: [String]
    let dateRange: String
    let onSearchMore: () -> Void
    let onStartVisit: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            // 전시 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color1)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.top, 10)

                if !artistNames.isEmpty {
                    Text(artistNames.joined(separator: ", "))
                        .font(LDFont.regular02)
                        .foregroundColor(LDColor.color3)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }

                Text(dateRange)
                    .font(LDFont.regular02)
                    .foregroundColor(LDColor.color3)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.bottom, 10)

                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .frame(height: 0.5)
                    .foregroundColor(LDColor.color3)
                    .padding(.bottom, 10)

            }

            // 액션 버튼들
            ArticleButtons(
                onSearchMore: onSearchMore,
                onStartVisit: onStartVisit
            )
        }
        .padding(.vertical, 8)
    }
}
