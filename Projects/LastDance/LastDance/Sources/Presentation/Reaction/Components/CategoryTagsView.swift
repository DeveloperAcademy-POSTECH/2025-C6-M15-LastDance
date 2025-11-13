//
//  CategoryTagsView.swift
//  LastDance
//
//  Created by donghee on 11/10/25.
//

import SwiftUI

/// 반응의 카테고리 태그 섹션
struct CategoryTagsView: View {
    let reaction: ReactionData
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        let showAll = viewModel.showAllReactions[reaction.id] ?? false
        let displayCategories = showAll ? reaction.categories : Array(reaction.categories.prefix(1))

        FlowLayout(spacing: 8) {
            ForEach(displayCategories, id: \.self) { category in
                CategoryTagView(text: category)
                    .onTapGesture {
                        if showAll {
                            viewModel.toggleShowAllReactions(id: reaction.id)
                        }
                    }
            }

            if !showAll && reaction.categories.count >= 2 {
                MoreCategoriesButton(
                    count: viewModel.hiddenCount(for: reaction),
                    action: { viewModel.toggleShowAllReactions(id: reaction.id) }
                )
            }
        }
    }
}
