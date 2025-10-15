//
//  ArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @StateObject private var viewModel = ArchiveViewModel()
    @EnvironmentObject private var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {
    
            HStack {
                Button(action: {
                    router.popLast()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                HStack {
                    Text("관람중")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: 58, height: 24)
                .background(Color.black)
                .cornerRadius(99)
            }
            .padding(.horizontal, 13)
            .padding(.top, 20)
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.exhibitionTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            // 작품 정보 섹션
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("현재까지 촬영한 이미지")
                        .font(.custom("Pretendard", size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.35))
                    
            
                    Text("\(viewModel.capturedArtworksCount)개의 작품")
                        .font(.custom("Pretendard", size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 25)

            ScrollView {
                if viewModel.isLoading {
                    // 로딩 상태
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, minHeight: 400)
                } else if viewModel.hasArtworks {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 31),
                            GridItem(.flexible(), spacing: 31)
                        ],
                        spacing: 24
                    ) {
                        ForEach(Array(viewModel.capturedArtworks.enumerated()), id: \.element.id) { index, artwork in
                            Image(artwork.localImagePath)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 157, height: 213)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .rotationEffect(.degrees(viewModel.getRotationAngle(for: index)))
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    // 빈 상태 메시지
                    VStack(spacing: 8) {
                        Text("마음에 드는 작품을 찾아")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(red: 0.81, green: 0.81, blue: 0.81))
                            .multilineTextAlignment(.center)
                        
                        Text("사진을 찍어보세요!")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(red: 0.81, green: 0.81, blue: 0.81))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 400)
                }
            }
            Spacer()
            Button(action: {
                router.push(.camera)
            }) {
                Text("촬영하기")
                    .font(.custom("Pretendard", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadCurrentExhibition()
        }
    }
}


#Preview {
    ArchiveView()
        .environmentObject(NavigationRouter())
        .modelContainer(SwiftDataManager.shared.container!)
}
