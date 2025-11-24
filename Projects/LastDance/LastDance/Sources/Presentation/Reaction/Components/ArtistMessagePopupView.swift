//
//  ArtistMessagePopupView.swift
//  LastDance
//
//  Created by donghee on 11/21/25.
//

import SwiftUI

/// 작가 반응 확인뷰에서만 사용되는 메시지 전송 팝업
struct MessagePopupView: View {
    @Binding var showMessagePopup: Bool
    @ObservedObject var viewModel: ArtworkReactionViewModel
    let reaction: ReactionData?
    @State private var messageText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image("bubbleOff")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 27, height: 25)

            Text("메시지에 반응해보세요")
                .font(LDFont.heading04)
                .foregroundStyle(LDColor.color1)
                .lineSpacing(5)

            TextField("10자 이내로 입력해주세요", text: $messageText)
                .font(LDFont.medium03)
                .foregroundStyle(LDColor.color1)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LDColor.color4, lineWidth: 1)
                )
                .focused($isTextFieldFocused)
                .padding(.horizontal, 12)
                .onChange(of: messageText) { newValue in
                    if newValue.count > 10 {
                        messageText = String(newValue.prefix(10))
                    }
                }

            Spacer().frame(height: 10)

            HStack(spacing: 9) {
                PopupButton(
                    title: "취소",
                    foregroundColor: LDColor.color1,
                    backgroundColor: LDColor.color4,
                    action: {
                        showMessagePopup = false
                    }
                )

                PopupButton(
                    title: "확인",
                    foregroundColor: .white,
                    backgroundColor: LDColor.color1,
                    action: {
                        guard let reaction = reaction else { return }
                        viewModel.sendMessage(reaction.id, messageText) { success in
                            if success {
                                messageText = ""
                                showMessagePopup = false
                            }
                        }
                    }
                )
            }
            .padding(.horizontal, 12)
        }
        .frame(width: 293)
        .padding(.top, 28)
        .padding(.bottom, 27)
        .background(LDColor.color5)
        .cornerRadius(14)
    }
}

/// 팝업 버튼
struct PopupButton: View {
    let title: String
    let foregroundColor: Color
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                Text(title)
                    .font(LDFont.heading06)
                    .foregroundStyle(foregroundColor)
                    .frame(maxWidth: .infinity, minHeight: 42)
                    .background(backgroundColor)
                    .cornerRadius(12)
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
}
