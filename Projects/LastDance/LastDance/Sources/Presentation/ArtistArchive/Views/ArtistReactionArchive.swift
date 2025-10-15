//
//  ArtistReactionArchive.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftUI
import SwiftData

struct ArtistReactionArchive: View {
    @StateObject private var viewModel = ArtistReactionArchiveViewModel()
    @EnvironmentObject private var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    router.popLast()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text(viewModel.exhibitionTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ScrollView {
                if viewModel.isLoading {
                    // 로딩 상태
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, minHeight: 400)
                } else if viewModel.hasReactionItems {
                    // 반응 목록 그리드
                    LazyVGrid(
                        columns: [
                            GridItem(.fixed(155), spacing: 27),
                            GridItem(.fixed(155), spacing: 27)
                        ],
                        spacing: 28
                    ) {
                        ForEach(viewModel.reactionItems) { reactionItem in
                            VStack(alignment: .leading, spacing: 12) {
                                // 반응 카드 이미지
                                ZStack(alignment: .bottomLeading) {
                                    Image(reactionItem.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 155, height: 219)
                                        .clipShape(RoundedRectangle(cornerRadius: 0))
                                    
                                    // 반응 카운터 배지
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text("\(reactionItem.reactionCount)")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                        .padding(.leading, 12)
                                        .padding(.bottom, 12)
                                }
                                
                                // 반응 카테고리
                                Text(reactionItem.category)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(width: 155, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                } else {
                    // 빈 상태
                    Text("아직 남긴 반응이 없습니다")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: 400)
                }
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}
