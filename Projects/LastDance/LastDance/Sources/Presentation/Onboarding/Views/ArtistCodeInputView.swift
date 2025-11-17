//
//  ArtistCodeInputView.swift
//  LastDance
//
//  Created by 아우신얀 on 11/17/25.
//

import SwiftUI

struct ArtistCodeInputView: View {
    @State private var codes: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 96)
            VStack(alignment: .leading) {
                Text("작가 코드를 입력해주세요")
                    .font(LDFont.heading02)

                Spacer().frame(height: 48)

                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        CodeTextField(
                            text: $codes[index],
                            focusedField: $focusedField,
                            index: index
                        )
                    }
                }

                Spacer().frame(height: 24)

                Button(
                    action: {

                    },
                    label: {

                        Text("코드를 잊으셨나요?")
                            .font(LDFont.regular03)
                            .foregroundStyle(LDColor.color2)
                            .underline(true, pattern: .solid)
                    }
                )
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.leading, 24)

            BottomButton(
                text: "다음", isEnabled: isCodeComplete,
                action: {
                    let fullcode = codes.joined()
                    Log.debug("fullcode: \(fullcode)")
                }
            )
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            focusedField = 0
        }
    }

    private var isCodeComplete: Bool {
        codes.contains { !$0.isEmpty }
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
            .frame(width: 48, height: 60)
            .background(
                Rectangle()
                    .foregroundColor(.clear)
                    .background(Color.white)
                    .cornerRadius(12)
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
                if !text.isEmpty && index < 5 {
                    focusedField = index + 1
                }
            }
            .onTapGesture {
                focusedField = index
            }
    }
}
#Preview {
    ArtistCodeInputView()
}
