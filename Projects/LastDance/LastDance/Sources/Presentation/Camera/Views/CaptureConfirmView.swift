//
//  CaptureConfirmView.swift
//  LastDance
//
//  Created by 배현진 on 10/10/25.
//

import SwiftUI

struct CaptureConfirmView: View {
    let image: UIImage
    var onUse: (UIImage) -> Void
    var onRetake: () -> Void

    var body: some View {
        GeometryReader { geo in
            let cardW = geo.size.width * CameraViewLayout.confirmCardWidthRatio
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
                    
                    HStack(spacing: 32) {
                        Button {
                            onRetake()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 24, weight: .semibold))
                                .padding(18)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        Button {
                            onUse(image)
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .padding(18)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                    .padding(.top, 24)
                }
                .padding(.vertical, CameraViewLayout.previewBottomInset)
            }
        }
    }
}
