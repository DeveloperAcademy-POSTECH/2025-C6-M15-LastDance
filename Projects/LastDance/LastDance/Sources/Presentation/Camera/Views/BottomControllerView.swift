//
//  BottomControllerView.swift
//  LastDance
//
//  Created by 배현진 on 10/13/25.
//

import SwiftUI

/// 카메라 필요 기능 컨트롤 버튼 화면
struct BottomControllerView: View {
  @ObservedObject var viewModel: CameraViewModel

  var body: some View {
    VStack(spacing: 0) {
      Spacer()

      ZoomControlView(viewModel: viewModel)
        .padding(.bottom, 40)

      ShutterButton {
        Task { await viewModel.captureSilentFrame() }
      }
      .padding(.bottom, 40)
    }
    .frame(maxWidth: .infinity)
  }
}
