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

    private var isArtist: Bool {
        var initialUserType: UserType?
        if let userTypeValue = UserDefaults.standard.string(forKey: UserDefaultsKey.userType.key) {
            initialUserType = UserType(rawValue: userTypeValue)
        }
        return initialUserType?.displayName == "작가"
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if let exhibition = viewModel.exhibition {
                    VStack {
                        Spacer()

                        if isArtist {
                            ArtistExhibitionPreviewCard(
                                exhibition: exhibition,
                                artistNames: viewModel.artistNames,
                                onConfirm: {
                                    handleArtistConfirm()
                                }
                            )
                            .padding(.horizontal)
                        } else {
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
                        }

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

    /// 작가 - 내 전시가 맞아요 버튼 처리
    private func handleArtistConfirm() {
        viewModel.selectExhibitionAsUserExhibition()
        router.push(.artistReaction)
    }

    /// 관람객 - 관람 시작하기 버튼 처리
    private func handleStartVisit() {
        viewModel.createVisitHistory { success in
            if success {
                viewModel.selectExhibitionAsUserExhibition()
                SwiftDataManager.shared.saveContext()
                router.push(.archive(id: exhibitionId))
            } else {
                Log.error("Failed to create visit history.")
            }
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
                .font(LDFont.heading04)
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
        //        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}
