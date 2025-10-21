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
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 타이틀
            HStack {
                Text("나의 전시")
                    .font(LDFont.heading02)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(155), spacing: 27),
                        GridItem(.fixed(155), spacing: 27)
                    ],
                    spacing: 24
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .bottomLeading) {
                            Image(viewModel.artworkImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 155, height: 219)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // 카운터
                            Circle()
                                .fill(Color.black)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text("\(viewModel.totalReactionCount)")
                                        .font(LDFont.heading04)
                                        .foregroundColor(LDColor.color6)
                                )
                                .padding(.leading, 12)
                                .padding(.bottom, 12)
                        }
                        .frame(width: 155, height: 219)
                        .onTapGesture {
                            router.push(.artistReactionArchiveView)
                        }
                        // 전시 제목
                        Text(viewModel.exhibitionTitle)
                            .font(LDFont.medium04)
                            .foregroundColor(.black)
                            .frame(width: 155, alignment: .leading)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 30)
                .padding(.bottom, 100)
            }
        }
        .background(LDColor.color6)
        .overlay(alignment: .bottomTrailing) {
            // 플로팅 버튼
            Button(action: {
                // TODO: 새 작품 추가 액션
            }) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(LDColor.color6)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 40)
        }
    }
}
