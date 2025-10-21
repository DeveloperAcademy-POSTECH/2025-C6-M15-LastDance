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

    let exhibitionId: Int
    
    var body: some View {
        VStack(spacing: 18) {
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
                }
            }
            
            if viewModel.hasExhibition {
                actionButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomNavigationBar(title: "전시정보") {
                router.popLast()
            }
        }
        .customAlert(
            isPresented: $viewModel.showErrorAlert,
            image: "warning",
            title: "아쉬워요!",
            message: "전시 정보를 불러오지 못했어요.\n전시 정보를 다시 확인해 주세요.",
            buttonText: "다시 찾기"
        ) {
            router.popLast()
        }
        .task {
            viewModel.fetchExhibition(by: exhibitionId)
        }
    }
    
    /// 관람객/작가에 따라 텍스트와 라우팅 분기
    private var actionButton: some View {
        var initialUserType: UserType?
        if let userTypeValue = UserDefaults.standard.string(forKey: UserDefaultsKey.userType.key) {
            initialUserType = UserType(rawValue: userTypeValue)
        }
        let isArtist = (initialUserType?.displayName == "작가")
        let title = isArtist ? "내 전시가 맞아요" : "관람하기"

        return BottomButton(text: title) {
            if isArtist {
                router.push(.artistReaction)
            } else {
                viewModel.selectExhibitionAsUserExhibition()
                router.push(.archive(id: exhibitionId))
            }
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
    let formatDateRange: (String, String) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exhibition.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(LDColor.black1)
            
            if !artistNames.isEmpty {
                Text(artistNames.joined(separator: ", "))
                    .font(LDFont.regular02)
                    .foregroundColor(LDColor.gray5)
            }
            Text(formatDateRange(exhibition.startDate, exhibition.endDate))
                .font(LDFont.regular02)
                .foregroundColor(LDColor.gray5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}

#Preview {
    ExhibitionDetailView(exhibitionId: 1)
        .environmentObject(NavigationRouter())
}
