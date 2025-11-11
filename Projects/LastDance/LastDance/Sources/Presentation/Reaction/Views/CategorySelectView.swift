//
//  CategorySelectView.swift
//  LastDance
//
//  Created by 신얀 on 10/11/25.
//

import SwiftUI

/// 반응 남기기 화면 중 카테고리 선택 뷰
struct CategorySelectView: View {
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var viewModel: ReactionInputViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("작품을 보고 떠오르는 감정을 선택해주세요")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 24)
                .padding(.bottom, 14)
                .padding(.horizontal, 24)

            Text("최대 \(viewModel.categoryLimit)개 선택할 수 있어요")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(red: 0.66, green: 0.66, blue: 0.66))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            Text("감정 카테고리")
                .font(.system(size: 20, weight: .semibold))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            CategoryListView(viewModel: viewModel)

            Spacer()

            BottomButton(
                text: "다음",
                isEnabled: !viewModel.selectedCategoryIds.isEmpty
            ) {
                router.push(.reactionTags)
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomNavigationBar(title: "반응 남기기") {
                router.popLast()
            }
        }
        .onAppear {
            if viewModel.categories.isEmpty {
                viewModel.loadCategories()
            }
        }
    }
}

/// 카테고리 선택지 목록을 위한 뷰
private struct CategoryListView: View {
    @ObservedObject var viewModel: ReactionInputViewModel

    var body: some View {
        VStack(spacing: 35) {
            ForEach(viewModel.categories) { category in
                let isSelected = viewModel.selectedCategoryIds.contains(category.id)
                Button {
                    viewModel.toggleCategory(category.id)
                } label: {
                    CheckCircleCategoryView(isSelected: isSelected, category: category)
                }
                .disabled(
                    !isSelected
                        && viewModel.selectedCategoryIds.count
                        >= viewModel.categoryLimit
                )
            }
        }
        .padding(.horizontal, 24)
    }
}
