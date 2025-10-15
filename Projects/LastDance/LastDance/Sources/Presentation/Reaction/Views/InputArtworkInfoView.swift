//
//  InputArtworkInfoView.swift
//  LastDance
//
//  Created by 아우신얀 on 10/15/25.
//

import SwiftUI

struct InputArtworkInfoView: View {
    @EnvironmentObject private var router: NavigationRouter

    @State private var showBottomSheet: Bool = false // 바텀시트의 상태를 알려주는 변수
    @State private var selectedTitle: String = ""
    @State private var selectedArtist: String = ""

    let image: UIImage
    var activeBtn: Bool = false // 하단 버튼 활성화를 알려주는 변수
    
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
                    
                    Spacer().frame(height: 20)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Button(action: {
                                showBottomSheet = true
                            }, label: {
                                Text("제목")
                                
                                Spacer()
                                
                                Text(selectedTitle.isEmpty ? "작품 제목을 선택해주세요" : selectedTitle)
                                    .foregroundColor(selectedTitle.isEmpty ? .gray : .primary)

                            })
                        }
                        .padding(.horizontal, 12)
                        
                        HStack {
                            Button(action: {
                                showBottomSheet = false
                            }, label: {
                                Text("작가")
                                    .foregroundColor(.gray)
                                Text("작가명을 알려주세요")
                            })
                        }
                        .padding(.horizontal, 12)
                    }
                    
                    Spacer().frame(height: 30)
                    
                    BottomButton(text: "다음",
                                 isEnabled: !selectedTitle.isEmpty && !selectedArtist.isEmpty,
                                 action: {
                        router.push(.category)
                    })
                }
                .padding(.vertical, CameraViewLayout.previewBottomInset)
            }
        }
    }
}

// MARK: CustomBottomSheet
/// 현재는
struct CustomBottomSheet: View {


    var body: some View {

    }
}
