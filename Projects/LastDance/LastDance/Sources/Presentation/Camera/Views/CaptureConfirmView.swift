//
//  CaptureConfirmView.swift
//  LastDance
//
//  Created by 배현진 on 10/10/25.
//

import SwiftUI

struct CaptureConfirmView: View {
  @EnvironmentObject private var router: NavigationRouter
  let imageData: Data
  let exhibitionId: Int

  private var image: UIImage? {
    UIImage(data: imageData)
  }

  @StateObject private var viewModel = CaptureConfirmViewModel()

  var body: some View {
    // 버튼 높이를 계산하기 위한 GeometryReader
    GeometryReader { geo in
      let safeBottom = geo.safeAreaInsets.bottom

      // 버튼 높이 계산
      let buttonsBlockHeight: CGFloat = 82 + 24 + safeBottom

      ZStack {
        Color(.systemBackground).ignoresSafeArea()

        if let image = image {
          // 화면 비율의 유연성을 위한 ScrollView 추가
          ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
              // 이미지 영역
              Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width)
                .clipped()
                .padding(.top, 45)

              ZStack {
                Button {
                  viewModel.uploadImage(image)
                } label: {
                  Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(LDColor.color6)
                    .padding(8)
                    .frame(width: 82, height: 82)
                    .background(LDColor.color1, in: Circle())
                }

                Button {
                  router.popLast()
                } label: {
                  Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(LDColor.black2)
                    .padding(8)
                    .frame(width: 52, height: 52)
                    .background(LDColor.gray3, in: Circle())
                }
                .offset(x: 100)
              }
              .padding(.top, 24)
              .padding(.bottom, 24)

              Color.clear.frame(height: safeBottom)
            }
            .frame(maxWidth: .infinity)
          }
          .ignoresSafeArea(.all, edges: .bottom)

        } else {
          Text("이미지를 불러올 수 없습니다.")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }
    .onChange(of: viewModel.uploadedImageUrl) { _, newUrl in
      if newUrl != nil, let image = image {
        router.push(.inputArtworkInfo(image: image, exhibitionId: exhibitionId, artistId: nil))
      }
    }
    .alert("업로드 실패", isPresented: .constant(viewModel.errorMessage != nil)) {
      Button("확인") {
        viewModel.errorMessage = nil
      }
    } message: {
      if let error = viewModel.errorMessage {
        Text(error)
      }
    }
    .toolbar {
      CustomNavigationBar(title: "") {
        router.popLast()
      }
    }
  }
}
