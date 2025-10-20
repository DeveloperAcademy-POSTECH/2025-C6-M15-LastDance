//
//  TagSelectView.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

import SwiftUI

struct TagSelectView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: TagSelectViewModel

    init(categories: [TagCategory]) {
        _viewModel = StateObject(
            wrappedValue: TagSelectViewModel(selectedCategories: categories)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("이 감정을 조금 더 자세히 표현해 본다면\n어떤 느낌에 가까운가요?")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 24)
                .padding(.bottom, 14)
                .padding(.horizontal, 24)

            Text("감정에 따른 감상평을 추천해드릴게요")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(red: 0.66, green: 0.66, blue: 0.66))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.categories) { category in
                        HStack(spacing: 8) {
                            CheckCircleCategoryView(isSelected: true, category: category)
                        }

                        TagListView(
                            tags: category.tags,
                            selected: viewModel.selectedTagIds,
                            color: category.color,
                            isFull: viewModel.isFull,
                            onTap: { viewModel.toggleTag($0) }
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            BottomButton(
                text: "완료",
                isEnabled: !viewModel.selectedTagIds.isEmpty
            ) {
                // TODO: - 반응 남기기 첫 뷰로 다시 이동. (선택 태그 전달)
            }
            .padding(.bottom, 10)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomNavigationBar(title: "반응 남기기") {
                router.popLast()
            }
        }
        .task {
            viewModel.loadTagsForSelectedCategories()
        }
    }
}
