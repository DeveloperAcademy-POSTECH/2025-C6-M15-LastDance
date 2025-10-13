//
//  ArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI

struct ArchiveView: View {
    @StateObject private var viewModel = ArchiveViewModel()
    @EnvironmentObject private var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {
            // 나가기 버튼
            HStack {
                Button(action: {
                    router.popLast()
                }) {
                    HStack {
                        Text("나가기")
                            .font(.custom("Pretendard", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .frame(width: 66, height: 40)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 박물관 정보
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.exhibitionTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // 관람중 배지
                HStack {
                    Text("관람중")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.primary.opacity(0.8))
                }
                .frame(width: 58, height: 24)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            // 작품 정보 섹션
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("현재까지 촬영한 이미지")
                        .font(.custom("Pretendard", size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                
                HStack {
                    Text("\(viewModel.capturedArtworksCount)개의 작품")
                        .font(.custom("Pretendard", size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 25)
            
            // 메인 컨텐츠 섹션
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Spacer()
                } else if viewModel.hasArtworks {
                    // TODO: 촬영한 이미지 그리드 구현
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(viewModel.capturedArtworks, id: \.id) { artwork in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(8)
                                .overlay(
                                    Text("작품 이미지")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                } else {
                    Spacer()
                    
                    // 빈 상태 메시지
                    VStack(spacing: 8) {
                        Text("마음에 드는 작품을 찾아")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("사진을 찍어보세요!")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // 하단 촬영하기 버튼
            Button(action: {
                router.push(.camera)
            }) {
                Text("촬영하기")
                    .font(.custom("Pretendard", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}


#Preview {
    ArchiveView()
        .environmentObject(NavigationRouter())
}
