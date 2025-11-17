//
//  ArtistCodeInputView.swift
//  LastDance
//
//  Created by 아우신얀 on 11/17/25.
//

import SwiftUI

struct ArtistCodeInputView: View {
    @EnvironmentObject private var viewModel: IdentitySelectionViewModel
    @EnvironmentObject private var router: NavigationRouter
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 96)
            VStack(alignment: .leading) {
                Text("작가 코드를 입력해주세요")
                    .font(LDFont.heading02)

                Spacer().frame(height: 48)

                HStack(spacing: 8) {
                    ForEach(0..<ArtistCodeConstants.codeLength, id: \.self) { index in
                        CodeTextField(
                            text: $viewModel.artistCodes[index],
                            focusedField: $focusedField,
                            index: index
                        )
                    }
                }

                Spacer().frame(height: 24)

                Button(
                    action: {
                        if let url = URL(string: ArtistCodeConstants.openChatURL) {
                            UIApplication.shared.open(url)
                        }
                    },
                    label: {
                        Text("코드를 잊으셨나요?")
                            .font(LDFont.regular03)
                            .foregroundStyle(LDColor.color2)
                            .underline(true, pattern: .solid)
                    }
                )
                .buttonStyle(PlainButtonStyle())

                Spacer().frame(height: 12)

                if viewModel.showArtistCodeError {
                    Text("사용할 수 없는 코드입니다. 다시 입력해주세요.")
                        .font(LDFont.regular03)
                        .foregroundStyle(LDColor.red4)
                }

                Spacer()
            }
            .padding(.leading, 24)

            BottomButton(
                text: "다음", isEnabled: viewModel.isCodeComplete,
                action: {
                    let fullcode = viewModel.artistCodes.joined()
                    Log.debug("fullcode: \(fullcode)")

                    viewModel.verifyArtistCode(fullcode) { success in
                        if success {
                            router.push(.articleArchiving)
                        }
                    }
                }
            )
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            focusedField = 0
            Log.debug(
                "codes: \(viewModel.artistCodes), isCodeComplete: \(viewModel.isCodeComplete)")
        }
    }
}

struct CodeTextField: View {
    @Binding var text: String
    @FocusState.Binding var focusedField: Int?

    let index: Int

    var body: some View {
        TextField("", text: $text)
            .multilineTextAlignment(.center)
            .font(LDFont.heading04)
            .textInputAutocapitalization(.never)
            .frame(width: 48, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.6), radius: 0.5, x: 0, y: 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.6)
                            .stroke(text.isEmpty ? Color.white : LDColor.color3, lineWidth: 1.5)
                    )
            )
            .focused($focusedField, equals: index)
            .onChange(of: text) { oldValue, newValue in
                // 한 글자만 입력되도록 제한
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }

                // 입력되면 다음 필드로 포커스 이동
                if !newValue.isEmpty && index < ArtistCodeConstants.codeLength - 1 {
                    focusedField = index + 1
                }

                // TODO: 보완 필요
                // 삭제 시 이전 필드로 포커스 이동
                if newValue.isEmpty && !oldValue.isEmpty && index > 0 {
                    focusedField = index - 1
                }
            }
            .onTapGesture {
                focusedField = index
            }
    }
}
