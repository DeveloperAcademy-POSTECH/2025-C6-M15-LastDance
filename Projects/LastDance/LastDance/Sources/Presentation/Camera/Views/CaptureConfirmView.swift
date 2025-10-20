//
//  CaptureConfirmView.swift
//  LastDance
//
//  Created by 배현진 on 10/10/25.
//

import SwiftUI

struct CaptureConfirmView: View {
    let image: UIImage
    var onUse: (String?) -> Void  // URL을 전달하도록 변경
    var onRetake: () -> Void

    @StateObject private var viewModel = CaptureConfirmViewModel()

    var body: some View {
        GeometryReader { geo in
            let cardW = geo.size.width
            let cardH = cardW / CameraViewLayout.aspect

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack {
                    Spacer()

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardW, height: cardH)
                        .clipped()
                    
                    ZStack {
                        Button {
                            viewModel.uploadImage(image)
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(8)
                                .frame(width: 82, height: 82)
                                .background(Color(red: 0.14, green: 0.14, blue: 0.14), in: Circle())
                        }
                        
                        Button {
                            onRetake()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.45))
                                .padding(8)
                                .frame(width: 52, height: 52)
                                .background(Color(red: 0.96, green: 0.96, blue: 0.96), in: Circle())
                        }
                        .offset(x: 100)
                    }
                    .padding(.top, 24)
                }
                .padding(.vertical, CameraViewLayout.previewBottomInset)
            }
        }
        .onChange(of: viewModel.uploadedImageUrl) { _, newUrl in
            if newUrl != nil {
                onUse(newUrl)
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
    }
}
