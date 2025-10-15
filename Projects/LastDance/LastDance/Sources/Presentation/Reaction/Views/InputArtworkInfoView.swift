//
//  InputArtworkInfoView.swift
//  LastDance
//
//  Created by 아우신얀 on 10/15/25.
//

import SwiftUI

struct InputArtworkInfoView: View {
    @EnvironmentObject private var router: NavigationRouter

    @State private var showBottomSheet: Bool = false  // 바텀시트의 상태를 알려주는 변수
    @State private var selectedTitle: String = ""
    @State private var selectedArtist: String = ""

    let image: UIImage
    var activeBtn: Bool = false  // 하단 버튼 활성화를 알려주는 변수

    var body: some View {

        GeometryReader { geo in
            let cardW = geo.size.width * CameraViewLayout.confirmCardWidthRatio
            let cardH = cardW / CameraViewLayout.aspect
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardW, height: cardH)
                        .clipped()

                    Spacer().frame(height: 20)

                    VStack(spacing: 12) {
                        InputFieldButton(
                            label: "제목",
                            value: selectedTitle,
                            placeholder: "작품 제목을 선택해주세요",
                            action: { showBottomSheet = true }
                        )

                        InputFieldButton(
                            label: "작가",
                            value: selectedArtist,
                            placeholder: "작가명을 알려주세요",
                            action: { showBottomSheet = false }
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    BottomButton(
                        text: "다음",
                        isEnabled: !selectedTitle.isEmpty
                            && !selectedArtist.isEmpty,
                        action: {
                            router.push(.category)
                        }
                    )
                }
            }

        }
    }
}

// MARK: - InputFieldButton
struct InputFieldButton: View {
    let label: String
    let value: String
    let placeholder: String
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Text(label)
                    .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.35))
                Spacer()

                Text(value.isEmpty ? placeholder : value)
                    .foregroundColor(
                        value.isEmpty
                            ? Color(red: 0.66, green: 0.66, blue: 0.66)
                            : .primary
                    )
            }
            .frame(minHeight: 60)
        }
        .padding(.horizontal, 12)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
    }
}

// MARK: - CustomBottomSheet
struct CustomBottomSheet: View {
    var body: some View {

    }
}
