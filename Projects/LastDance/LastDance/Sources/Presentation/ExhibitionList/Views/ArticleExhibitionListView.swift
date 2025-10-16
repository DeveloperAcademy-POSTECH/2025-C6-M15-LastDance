//
//  ArticleExhibitionListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI
import SwiftData

struct ArticleExhibitionListContent: View {
    let exhibitions: [Exhibition]
    @ObservedObject var viewModel: ArticleExhibitionListViewModel

    var body: some View {
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
}

struct ArticleExhibitionListNextButton: View {
    @EnvironmentObject private var router: NavigationRouter
    @ObservedObject var viewModel: ArticleExhibitionListViewModel

    var body: some View {
        BottomButton(text: "다음") {
            if let exhibitionId = viewModel.tapNextButton() {
                router.push(.articleList(selectedExhibitionId: exhibitionId))
            }
        }
    }
}

struct ArticleExhibitionListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArticleExhibitionListViewModel()
    @Query private var exhibitions: [Exhibition]

    var body: some View {
        VStack(spacing: 0) {
            PageIndicator(totalPages: 2, currentPage: 1)
                .padding(.horizontal, -20)

            TitleSection(title: "참여한 전시를 알려주세요", subtitle: "전시명")

            ArticleExhibitionListContent(exhibitions: exhibitions, viewModel: viewModel)

            Spacer()

            ArticleExhibitionListNextButton(viewModel: viewModel)
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
}

#Preview {
    ArticleExhibitionListView()
        .environmentObject(NavigationRouter())
}
