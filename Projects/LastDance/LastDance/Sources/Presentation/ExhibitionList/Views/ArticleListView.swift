//
//  ArticleListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

struct ArticleListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArticleListViewModel()
    @Environment(\.keyboardManager) private var keyboardManager

    let selectedExhibitionId: String

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                PageIndicator(totalPages: 2, currentPage: 1)
                    .padding(.horizontal, -20)

                titleSection

                searchTextField

                artistList(availableHeight: geometry.size.height - 300)

                Spacer()

                nextButton
            }
            .padding(.top, 18)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CustomNavigationBar(title: "전시찾기") {
                    router.popLast()
                }
            }
        }
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("어떤 작가님이신가요?")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("작가명")
                .font(Font.custom("SF Pro Text", size: 17))
                .foregroundStyle(Color.black)
                .padding(.top, 28)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    var searchTextField: some View {
        TextField("작가명을 선택해주세요", text: $viewModel.searchText)
            .font(Font.custom("SF Pro Text", size: 17))
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 1)
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.bottom, 8)
    }

    func artistList(availableHeight: CGFloat) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredArtists, id: \.id) { artist in
                    ArticleArtistRow(
                        artist: artist,
                        isSelected: viewModel.selectedArtistId == artist.id
                    ) {
                        viewModel.selectArtist(artist)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .frame(height: 400)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.5)
                .stroke(Color.black.opacity(0.18), lineWidth: 1)
        )
    }

    var nextButton: some View {
        BottomButton(text: "다음") {
            if let artistId = viewModel.tapNextButton() {
                router.push(.completeArticleList(selectedExhibitionId: selectedExhibitionId, selectedArtistId: artistId))
            }
        }
    }
}

/// 작가 목록 행 컴포넌트
struct ArticleArtistRow: View {
    let artist: Artist
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(artist.name)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(red: 0.93, green: 0.93, blue: 0.93) : Color.clear)
                )
                .padding(.horizontal, isSelected ? 8 : 0)
        }
    }
}

/// 페이지 인디케이터
struct PageIndicatorForArticleList: View {
    let totalPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<totalPages, id: \.self) { index in
                Rectangle()
                    .fill(index == currentPage ? Color.black : Color.black.opacity(0.18))
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    ArticleListView(selectedExhibitionId: "exhibition_light")
        .environmentObject(NavigationRouter())
}
