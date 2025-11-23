//
//  ClipCustomAlert.swift
//  LastDance
//
//  Created by 배현진 on 11/21/25.
//

import SwiftUI

struct ClipCustomAlert: View {
    let image: String
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void
    let cancelAction: (() -> Void)?  // 취소 버튼 액션 (옵셔널)

    var body: some View {
        VStack(spacing: 0) {

            // 이미지가 있을 때만 보여주기
            if !image.isEmpty {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 41)
                    .padding(.top, 28)
                    .padding(.horizontal, 16)
            }

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.top, image.isEmpty ? 28 : 8)  // 이미지 없으면 위 여백 보정
                .padding(.horizontal, 16)

            // 메시지가 있을 때만 보여주기
            if !message.isEmpty {
                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.39, green: 0.39, blue: 0.39))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
            }

            // 메시지가 있을 때만 아래 spacer 유지
            if !message.isEmpty {
                Spacer().frame(height: 22)
            } else {
                Spacer().frame(height: 22)  // 타이틀-only 버전용 약간의 여백 조정
            }

            if let cancelAction = cancelAction {
                HStack(spacing: 8) {
                    Button(action: cancelAction) {
                        Text("취소")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.14, green: 0.14, blue: 0.14))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(12)
                    }

                    Button(action: action) {
                        Text(buttonText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(.white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color(red: 0.14, green: 0.14, blue: 0.14))
                            .cornerRadius(12)
                    }
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 12)
            } else {
                Button(action: action) {
                    Text(buttonText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(.white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color(red: 0.14, green: 0.14, blue: 0.14))
                        .cornerRadius(12)
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 12)
            }
        }
        .frame(width: 293)
        .background(Color(.white))
        .cornerRadius(14)
    }
}

/// Alert를 표시하기 위한 Modifier
struct CustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let image: String
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void
    let cancelAction: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // 배경 탭 시 닫지 않음
                        }

                    ClipCustomAlert(
                        image: image,
                        title: title,
                        message: message,
                        buttonText: buttonText,
                        action: action,
                        cancelAction: cancelAction
                    )
                }
                .ignoresSafeArea(.all)
            }
        }
    }
}
