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
                .font(LDFont.heading04)
                .foregroundColor(.black)
                .padding(.top, image.isEmpty ? 28 : 8)  // 이미지 없으면 위 여백 보정
                .padding(.horizontal, 16)

            // 메시지가 있을 때만 보여주기
            if !message.isEmpty {
                Text(message)
                    .font(LDFont.regular03)
                    .foregroundColor(LDColor.gray1)
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

            // 버튼 영역 (변경 없음)
            if let cancelAction = cancelAction {
                HStack(spacing: 8) {
                    Button(action: cancelAction) {
                        Text("취소")
                            .font(LDFont.heading06)
                            .foregroundColor(LDColor.color1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(LDColor.color4)
                            .cornerRadius(12)
                    }

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
#Preview {
    CustomAlert(
        image: "",  // 아무 이미지 안 보임
        title: "정말 삭제하시겠습니까?",
        message: "",  // 메시지 안 보임
        buttonText: "확인",
        action: {
            print("확인 버튼 눌림")
        },
        cancelAction: {
            print("취소 버튼 눌림")
        }
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
