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
        GeometryReader { geometry in
            ScrollView { // 이 부분 사용할 때 LazyVStack 써야하는지
                if let exhibition = viewModel.exhibition {
                    VStack {
                        Spacer()
                        
                        ExhibitionPreviewCard(
                            exhibition: exhibition,
                            artistNames: viewModel.artistNames,
                            onSearchMore: {
                                router.popLast()
                            },
                            onStartVisit: {
                                handleStartVisit()
                            }
                        )
                        .padding(.horizontal)
                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
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
    /// 사용자 타입에 따라 "관람 시작하기" 또는 "내 전시가 맞아요" 버튼 동작 처리
    private func handleStartVisit() {
        var initialUserType: UserType?
        if let userTypeValue = UserDefaults.standard.string(forKey: UserDefaultsKey.userType.key) {
            initialUserType = UserType(rawValue: userTypeValue)
        }
        let isArtist = (initialUserType?.displayName == "작가")
        
        if isArtist {
            router.push(.artistReaction)
        } else {
            router.push(.archive(id: exhibitionId))
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
