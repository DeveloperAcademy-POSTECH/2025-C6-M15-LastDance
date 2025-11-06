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
        GeometryReader { geo in
            let cardW = geo.size.width
            let cardH = cardW / CameraViewLayout.aspect

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if let image = image {
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
                    }
                    .padding(.vertical, CameraViewLayout.previewBottomInset)
                } else {
                    Text("이미지를 불러올 수 없습니다.")
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
