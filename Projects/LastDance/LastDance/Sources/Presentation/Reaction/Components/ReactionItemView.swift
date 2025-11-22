//
//  ReactionItemView.swift
//  LastDance
//
//  Created by donghee on 11/10/25.
//

import SwiftUI

/// 개별 반응 아이템 뷰
struct ReactionItemView: View {
    let reaction: ReactionData
    @ObservedObject var viewModel: ArtworkReactionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 댓글 섹션
            if !reaction.comment.isEmpty {
                ReactionCommentSection(
                    reaction: reaction,
                    viewModel: viewModel
                )
            }
        }
        .padding(.vertical, 8)
    }
}
