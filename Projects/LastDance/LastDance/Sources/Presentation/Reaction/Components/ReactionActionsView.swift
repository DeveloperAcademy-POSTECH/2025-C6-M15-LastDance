//
//  ReactionActionsView.swift
//  LastDance
//
//  Created by 배현진 on 11/24/25.
//

import SwiftUI

/// 작가 flow: 반응 보기에서 이모지 / 말풍선 버튼
struct ReactionActionsView: View {
    let reaction: ReactionData
    @ObservedObject var viewModel: ArtworkReactionViewModel
    @Binding var showEmojiPopup: Bool
    @Binding var emojiPopupPosition: CGRect
    @Binding var showMessagePopup: Bool
    @Binding var selectedReactionForMessage: ReactionData?

    var body: some View {
        HStack(spacing: 18) {
            GeometryReader { proxy in
                Button(action: {
                    handleEmojiButtonTap(proxy: proxy)
                }) {
                    emojiImage
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
    }

    private var emojiImage: some View {
        Group {
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
    }

    private func handleEmojiButtonTap(proxy: GeometryProxy) {
        // 이미 이모지 선택된 경우는 비활성화 상태라 이 함수 안 들어옴
        if viewModel.getSelectedEmoji(for: reaction.id) == nil {
            if viewModel.selectedReactionId == reaction.id && showEmojiPopup {
                // 이미 열려있으면 닫기
                showEmojiPopup = false
                viewModel.selectedReactionId = nil
            } else {
                // 새로 열기
                viewModel.selectedReactionId = reaction.id
                emojiPopupPosition = proxy.frame(in: .global)
                showEmojiPopup = true
            }
        }
    }
}
