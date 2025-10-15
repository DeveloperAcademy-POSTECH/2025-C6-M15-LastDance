//
//  ExhibitionDetailView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct ExhibitionDetailView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ExhibitionDetailViewModel()

    let exhibitionId: String

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let exhibition = viewModel.exhibition {
                    VStack(spacing: 0) {
                        ExhibitionImageSection(coverImageName: exhibition.coverImageName)

                        ExhibitionInfoSection(
                            exhibition: exhibition,
                            artistNames: viewModel.artistNames,
                            formatDateRange: viewModel.formatDateRange
                        )
                    }
                } else {
                    Text("전시 정보를 불러올 수 없습니다")
                        .foregroundStyle(.gray)
                        .padding(.top, 100)
                }
            }

            if viewModel.exhibition != nil {
                ViewButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomNavigationBar(title: "전시정보") {
                router.popLast()
            }
        }
        .task {
            viewModel.fetchExhibition(by: exhibitionId)
        }
    }

    var ViewButton: some View {
        BottomButton(text: "관람하기") {
            // TODO: 다음 화면으로 네비게이션
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
    }
}

/// 전시 커버 이미지 섹션
struct ExhibitionImageSection: View {
    let coverImageName: String?

    var body: some View {
        if let imageName = coverImageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 345, height: 488)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 345, height: 488)
                .overlay(
                    Text("이미지 없음")
                        .foregroundStyle(.gray)
                )
        }
    }
}

/// 전시 정보 섹션
struct ExhibitionInfoSection: View {
    let exhibition: Exhibition
    let artistNames: [String]
    let formatDateRange: (Date, Date) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exhibition.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.16, green: 0.16, blue: 0.16))

            if !artistNames.isEmpty {
                Text(artistNames.joined(separator: ", "))
                    .font(Font.custom("Pretendard", size: 16))
                    .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.35))
            }

            Text(formatDateRange(exhibition.startDate, exhibition.endDate))
                .font(Font.custom("Pretendard", size: 16))
                .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.35))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}

#Preview {
    ExhibitionDetailView(exhibitionId: "exhibition_light")
        .environmentObject(NavigationRouter())
}
