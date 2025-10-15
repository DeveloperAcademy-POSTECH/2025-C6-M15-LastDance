//
//  CustomAlert.swift
//  LastDance
//
//  Created by donghee on 10/15/25.
//

import SwiftUI

/// 커스텀 Alert 컴포넌트
struct CustomAlert: View {
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(
                Font.custom("Pretendard", size: 18)
                .weight(.semibold)
                )
                .foregroundColor(.black)
                .padding(.top, 24)

            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 16)

            Button(action: action) {
                Text(buttonText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
        .frame(width: 270)
        .background(Color.white)
        .cornerRadius(12)
    }
}

/// Alert를 표시하기 위한 Modifier
struct CustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 배경 탭 시 닫지 않음
                    }

                CustomAlert(
                    title: title,
                    message: message,
                    buttonText: buttonText,
                    action: action
                )
            }
        }
    }
}

extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        buttonText: String,
        action: @escaping () -> Void
    ) -> some View {
        modifier(CustomAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            buttonText: buttonText,
            action: action
        ))
    }
}

#Preview {
    CustomAlert(
        title: "아쉬워요!",
        message: "전시 정보를 불러오지 못했어요.\n전시 정보를 다시 확인해 주세요.",
        buttonText: "다시 찾기"
    ) {
        print("Alert button tapped")
    }
}
