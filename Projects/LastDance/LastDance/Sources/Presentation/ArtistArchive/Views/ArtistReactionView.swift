//
//  ArtistReactionView.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftUI
import SwiftData

struct ArtistReactionView: View {
    @StateObject private var viewModel = ArtistReactionViewModel()
    @EnvironmentObject private var router: NavigationRouter
    
    private let gridColumns: [GridItem] = [
        GridItem(.fixed(155), spacing: 16),
        GridItem(.fixed(155), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("나의 전시")
                .font(LDFont.heading02)
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.top, 20)
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 그리드
                ScrollView {
                    LazyVGrid(
                        columns: gridColumns,
                        spacing: 24
                    ) {
                        ForEach(Array(viewModel.exhibitions.enumerated()), id: \.element.id) { index, exhibition in
                            ArtistExhibitionCard(
                                exhibition: exhibition
                            )
                            .onTapGesture {
                                router.push(.artistReactionArchiveView(exhibitionId: exhibition.id))
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 30)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(LDColor.color6)
        .overlay(alignment: .bottomTrailing) {
            // 플로팅 버튼
            CircleAddButton {
                router.push(.articleExhibitionList)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            viewModel.loadExhibitionsFromDB()
        }
    }
}

// MARK: - Components

struct ArtistExhibitionCard: View {
    let exhibition: MockExhibitionData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 포스터 이미지 + 반응 카운터
            ZStack(alignment: .bottomLeading) {
                Image(exhibition.coverImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 155, height: 219)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("\(exhibition.reactionCount)")
                            .font(LDFont.heading07)
                            .foregroundColor(.white)
                    )
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
            }
            
            // 전시 제목 (고정 높이로 정렬 보장)
            Text(exhibition.title)
                .font(LDFont.medium04)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 155, height: 44, alignment: .topLeading)
        }
    }
}
