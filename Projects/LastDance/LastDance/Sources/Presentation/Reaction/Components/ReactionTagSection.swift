//
//  ReactionTagSection.swift
//  LastDance
//
//  Created by donghee on 11/10/25.
//

import SwiftUI

/// 반응의 태그 섹션 (카테고리 태그)
struct ReactionTagSection: View {
    let reaction: ReactionData
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        if !reaction.categories.isEmpty {
            CategoryTagsView(
                reaction: reaction,
                viewModel: viewModel
            )
        }
    }
}
