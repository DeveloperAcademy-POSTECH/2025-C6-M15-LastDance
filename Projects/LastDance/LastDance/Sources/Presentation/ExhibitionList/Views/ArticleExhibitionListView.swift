//
//  ArticleExhibitionListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI
import SwiftData

struct ArticleExhibitionListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArticleExhibitionListViewModel()
    @Query private var exhibitions: [Exhibition]

    var body: some View {
        VStack(spacing: 0) {
            PageIndicator(totalPages: 2, currentPage: 1)
                .padding(.horizontal, -20)

            titleSection

            exhibitionList

            Spacer()

            nextButton
        }
        .padding(.top, 18)
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomNavigationBar(title: "전시찾기") {
                router.popLast()
            }
        }
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("참여한 전시를 알려주세요")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("전시명")
                .font(Font.custom("Pretendard", size: 16))
                .foregroundStyle(Color.black)
                .padding(.top, 24)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    var exhibitionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(exhibitions, id: \.id) { exhibition in
                    SelectionRow(
                        title: exhibition.title,
                        isSelected: viewModel.selectedExhibitionId == exhibition.id
                    ) {
                        viewModel.selectExhibition(exhibition)
                    }
                }
            }
        }
    }

    var nextButton: some View {
        BottomButton(text: "다음") {
            if let exhibitionId = viewModel.tapNextButton() {
                router.push(.articleList(selectedExhibitionId: exhibitionId))
            }
        }
    }
}

#Preview {
    ArticleExhibitionListView()
        .environmentObject(NavigationRouter())
}
