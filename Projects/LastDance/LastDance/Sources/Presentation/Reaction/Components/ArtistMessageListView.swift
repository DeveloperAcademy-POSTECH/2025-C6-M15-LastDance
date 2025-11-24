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
                Text(Date.formatShortDate(from: reaction.createdAt))
                    .font(LDFont.medium05)
                    .foregroundColor(LDColor.color3)

                Spacer().frame(height: 8)

                // 댓글 텍스트
                if !reaction.comment.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.displayText(for: reaction))
                            .font(LDFont.medium03)
                            .foregroundColor(LDColor.color1)
                            .lineLimit(viewModel.expandedReactions.contains(reaction.id) ? nil : 3)
                            .lineSpacing(6)

                        // TODO: 글자수 말고 글자 높이, 너비로 접기-더보기 수정
                        if reaction.comment.count > 80 {
                            Button(action: {
                                viewModel.handleExpandToggle(for: reaction)
                            }) {
                                Text(
                                    viewModel.expandedReactions.contains(reaction.id) ? "접기" : "더보기"
                                )
                                .font(LDFont.medium05)
                                .foregroundColor(LDColor.color3)
                            }
                        }
                    }
                    .padding(.bottom, 12)
                }

                HStack(spacing: 18) {
                    GeometryReader { proxy in
                        Button(action: {
                            // 이미지 리스트에서 클릭된 이모지가 없다면 토글 가능
                            if viewModel.getSelectedEmoji(for: reaction.id) == nil {
                                if viewModel.selectedReactionId == reaction.id && showEmojiPopup {
                                    // 이미 팝업이 열려있으면 닫기
                                    showEmojiPopup = false
                                    viewModel.selectedReactionId = nil
                                } else {
                                    // 팝업 열기
                                    viewModel.selectedReactionId = reaction.id
                                    emojiPopupPosition = proxy.frame(in: .global)
                                    showEmojiPopup = true
                                }
                            }
                        }) {
                            // 선택된 이미지가 존재한다면 그걸로 표시
                            if let selectedEmoji = viewModel.getSelectedEmoji(for: reaction.id) {
                                Image(selectedEmoji)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 31, height: 29)

                            } else {
                                Image(
                                    viewModel.selectedReactionId == reaction.id && showEmojiPopup
                                        ? "defaultImageFill" : "defaultImage"
                                )
                                .resizable()
                                .scaledToFill()
                                .frame(width: 26, height: 27)
                            }
                        }
                        .disabled(viewModel.getSelectedEmoji(for: reaction.id) != nil)
                    }
                    .frame(width: 26, height: 27)

                    Button(action: {
                        selectedReactionForMessage = reaction
                        showMessagePopup = true
                    }) {
                        Image(reaction.artistMessages.isEmpty ? "bubbleOff" : "bubbleOn")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 26, height: 25)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }

                // 작가가 남긴 답글들
                if !reaction.artistMessages.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(reaction.artistMessages) { artistMessage in
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
