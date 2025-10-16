//
//  ArchiveHomeView.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI

struct ArchiveHomeView: View {
    @StateObject private var viewModel = ArchiveHomeViewModel()
    @EnvironmentObject private var router: NavigationRouter
    
    private let gridColumns: [GridItem] = [
        GridItem(.fixed(155), spacing: 16),
        GridItem(.fixed(155), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
        
            Text("나의 전시")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.top, 20)
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.hasExhibitions {
                // 전시 그리드
                ScrollView {
                    LazyVGrid(
                        columns: gridColumns,
                        spacing: 24
                    ) {
                        ForEach(0..<viewModel.exhibitions.count, id: \.self) { index in
                            let exhibition = viewModel.exhibitions[index]
                            ExhibitionCardView(
                                exhibition: exhibition,
                                dateString: viewModel.dateString(for: exhibition)
                            )
                            .offset(y: index % 2 == 0 ? 0 : 40)
                            .onTapGesture {
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 30)
                    .padding(.bottom, 100)
                }
            } else {
                // 빈 상태
                VStack(spacing: 38) {
                    CircleAddButton {
                        router.push(.exhibitionList)
                    }
                    Text("전시 관람을 시작해 나만의\n전시 보관소를 만들어보세요")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white)
        .overlay(alignment: .bottomTrailing) {
            // 플로팅 버튼 (전시가 있을 때만)
            if viewModel.hasExhibitions {
                CircleAddButton {
                    router.push(.exhibitionList)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
struct ExhibitionCardView: View {
    let exhibition: Exhibition
    let dateString: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 전시 포스터 이미지
            if let coverImageName = exhibition.coverImageName {
                Image(coverImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 155, height: 219)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 155, height: 219)
                    .overlay(
                        Text("이미지 없음")
                            .font(.caption)
                            .foregroundColor(.gray)
                    )
            }
            // 전시 제목
            Text(exhibition.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 155, alignment: .leading)
            
            // 날짜
            Text(dateString)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.35))
                .frame(width: 155, alignment: .leading)
        }
    }
}

#Preview {
    ArchiveHomeView()
        .environmentObject(NavigationRouter())
        .modelContainer(SwiftDataManager.shared.container!)
}
