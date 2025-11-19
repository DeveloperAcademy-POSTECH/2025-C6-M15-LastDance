//
//  CustomAlert.swift
//  LastDance
//
//  Created by donghee on 10/15/25.
//

import SwiftUI

/// 커스텀 Alert 컴포넌트
struct CustomAlert: View {
    let image: String
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void
    let cancelAction: (() -> Void)?  // 취소 버튼 액션 (옵셔널)

    var body: some View {
        VStack(spacing: 0) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 41)
                .padding(.top, 28)
                .padding(.horizontal, 16)

            Text(title)
                .font(LDFont.heading04)
                .foregroundColor(.black)
                .padding(.top, 8)
                .padding(.horizontal, 16)

            Text(message)
                .font(LDFont.regular03)
                .foregroundColor(LDColor.gray1)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 16)

            Spacer().frame(height: 22)

            if let cancelAction = cancelAction {
                // 버튼 2개 (취소 + 확인)
                HStack(spacing: 8) {
                    // 취소 버튼
                    Button(action: cancelAction) {
                        Text("취소")
                            .font(LDFont.heading06)
                            .foregroundColor(LDColor.color1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(LDColor.color4)
                            .cornerRadius(12)
                    }

                    // 확인 버튼
                    Button(action: action) {
                        Text(buttonText)
                            .font(LDFont.heading06)
                            .foregroundColor(LDColor.color6)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(LDColor.color1)
                            .cornerRadius(12)
                    }
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 12)
            } else {
                // 버튼 1개 (확인만)
                Button(action: action) {
                    Text(buttonText)
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.color6)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(LDColor.color1)
                        .cornerRadius(12)
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 12)
            }
        }
        .frame(width: 293)
        .background(LDColor.color6)
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

                    CustomAlert(
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
