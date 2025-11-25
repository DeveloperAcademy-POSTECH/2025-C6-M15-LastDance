//
//  ArtistMessageListView.swift
//  LastDance
//
//  Created by donghee on 11/21/25.
//

import SwiftUI

/// 작가 반응 메시지 리스트 뷰
struct MessageListView: View {
    @ObservedObject var viewModel: ArtworkReactionViewModel
    @Binding var showEmojiPopup: Bool
    @Binding var emojiPopupPosition: CGRect
    @Binding var showMessagePopup: Bool
    @Binding var selectedReactionForMessage: ReactionData?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<viewModel.reactions.count, id: \.self) { index in
                MessageItemView(
                    reaction: viewModel.reactions[index],
                    index: index,
                    viewModel: viewModel,
                    isLast: index == viewModel.reactions.count - 1,
                    showEmojiPopup: $showEmojiPopup,
                    emojiPopupPosition: $emojiPopupPosition,
                    showMessagePopup: $showMessagePopup,
                    selectedReactionForMessage: $selectedReactionForMessage
                )
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 100)
    }
}

/// 작가 반응 메시지 아이템 뷰
struct MessageItemView: View {
    let reaction: ReactionData
    let index: Int
    @ObservedObject var viewModel: ArtworkReactionViewModel
    let isLast: Bool
    @Binding var showEmojiPopup: Bool
    @Binding var emojiPopupPosition: CGRect
    @Binding var showMessagePopup: Bool
    @Binding var selectedReactionForMessage: ReactionData?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // 날짜
                Text(Date.formatShortDate(from: reaction.createdAt))
                    .font(LDFont.medium05)
                    .foregroundColor(LDColor.color3)

                Spacer().frame(height: 8)

                // 댓글 텍스트 + 더보기/접기
                if !reaction.comment.isEmpty {
                    ReactionCommentView(
                        comment: reaction.comment,
                        isExpanded: viewModel.expandedReactions.contains(reaction.id),
                        onToggleExpand: {
                            viewModel.handleExpandToggle(for: reaction)
                        }
                    )
                    .padding(.bottom, 12)
                }

                // 이모지 / 말풍선 버튼
                ReactionActionsView(
                    reaction: reaction,
                    viewModel: viewModel,
                    showEmojiPopup: $showEmojiPopup,
                    emojiPopupPosition: $emojiPopupPosition,
                    showMessagePopup: $showMessagePopup,
                    selectedReactionForMessage: $selectedReactionForMessage
                )

                // 작가 답글
                if !reaction.artistMessages.isEmpty {
                    ArtistMessagesView(messages: reaction.artistMessages)
                        .padding(.top, 24)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 12)
            .padding(.horizontal, 24)

            if !isLast {
                Rectangle()
                    .fill(LDColor.gray8)
                    .frame(height: 1)
            }
        }
    }
}

private struct ArtistMessagesView: View {
    let messages: [ReactionData.ArtistMessage]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(messages) { artistMessage in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Image("reactionLine")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 14, height: 12)

                        Text("내 답글")
                            .font(LDFont.medium05)
                            .foregroundColor(LDColor.color2)
                    }

                    Text(artistMessage.message)
                        .font(LDFont.medium03)
                        .foregroundColor(LDColor.color1)
                        .lineSpacing(4)
                }
            }
        }
    }
}
