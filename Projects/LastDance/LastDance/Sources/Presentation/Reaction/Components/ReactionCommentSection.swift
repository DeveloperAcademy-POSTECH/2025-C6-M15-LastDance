//
//  ReactionCommentSection.swift
//  LastDance
//
//  Created by donghee on 11/10/25.
//

import SwiftUI

/// 반응의 댓글 섹션
struct ReactionCommentSection: View {
    let reaction: ReactionData
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.displayText(for: reaction))
                .font(LDFont.medium03)
                .lineLimit(viewModel.expandedReactions.contains(reaction.id) ? nil : 3)
                .lineSpacing(10)
                .animation(.easeInOut(duration: 0.3), value: viewModel.expandedReactions.contains(reaction.id))

            if reaction.comment.count > 100 {
                Button(action: {
                    viewModel.handleExpandToggle(for: reaction)
                }) {
                    Text(viewModel.expandedReactions.contains(reaction.id) ? "접기" : "더보기")
                        .font(LDFont.medium05)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
