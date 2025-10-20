//
//  ExhibitionPreviewCard.swift
//  LastDance
//
//  Created by donghee on 10/20/25.
//

import SwiftUI
import Foundation

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
                dateRange: Date.formatDateRange(start: exhibition.startDate, end: exhibition.endDate),
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
        if let imageName = imageName {
            Image(imageName)
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
        } else {
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

// MARK: - ExhibitionPreviewInfo

struct ExhibitionPreviewInfo: View {
    let title: String
    let artistNames: [String]
    let dateRange: String
    let onSearchMore: () -> Void
    let onStartVisit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 전시 정보
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(Font.custom("Pretendard", size: 18).weight(.semibold))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                if !artistNames.isEmpty {
                    Text(artistNames.joined(separator: ", "))
                        .font(Font.custom("Pretendard", size: 16))
                        .foregroundColor(Color(red: 0.73, green: 0.73, blue: 0.73))
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                
                Text(dateRange)
                    .font(Font.custom("Pretendard", size: 16))
                    .foregroundColor(Color(red: 0.73, green: 0.73, blue: 0.73))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .frame(height: 0.5)
                    .foregroundColor(Color(red: 0.78, green: 0.78, blue: 0.78))
            }
            .padding(.top, 14)
            
            // 액션 버튼들
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
            .padding(.bottom, 14)
        }
    }
}
