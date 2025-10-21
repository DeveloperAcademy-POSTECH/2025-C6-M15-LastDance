//
//  ArticleListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

struct ArticleListSearchTextField: View {
    @Binding var searchText: String

    var body: some View {
        TextField("작가명을 선택해주세요", text: $searchText)
            .font(LDFont.regular01)
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(LDColor.color6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 1)
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.bottom, 8)
    }
}

struct ArticleListContent: View {
    @ObservedObject var viewModel: ArticleListViewModel

    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(LDColor.color6)
    }

    private var borderShape: some View {
        RoundedRectangle(cornerRadius: 8)
            .inset(by: 0.5)
            .stroke(Color.black.opacity(0.18), lineWidth: 1)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredArtists, id: \.id) { artist in
                    let artistIdInt = artist.id.hashValue
                    ArticleArtistRow(
                        artist: artist,
                        isSelected: viewModel.selectedArtistId == artistIdInt
                    ) {
                        viewModel.selectArtist(artist)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .frame(height: 300)
        .background(backgroundShape)
        .overlay(borderShape)
    }
}

struct ArticleListNextButton: View {
    @EnvironmentObject private var router: NavigationRouter
    let selectedExhibitionId: Int
    @ObservedObject var viewModel: ArticleListViewModel

    var body: some View {
        BottomButton(text: "다음") {
            if let artistId = viewModel.tapNextButton() {
                router.push(.completeArticleList(selectedExhibitionId: selectedExhibitionId, selectedArtistId: artistId))
            }
        }
    }
}

struct ArticleListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArticleListViewModel()
    @Environment(\.keyboardManager) private var keyboardManager

    let selectedExhibitionId: Int

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                PageIndicator(totalPages: 2, currentPage: 1)
                    .padding(.horizontal, -20)

                TitleSection(title: "어떤 작가님이신가요?", subtitle: "작가명")

                ArticleListSearchTextField(searchText: $viewModel.searchText)

                ArticleListContent(viewModel: viewModel)

                Spacer()

                ArticleListNextButton(
                    selectedExhibitionId: selectedExhibitionId,
                    viewModel: viewModel
                )
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
}

/// 작가 목록 행 컴포넌트
struct ArticleArtistRow: View {
    let artist: Artist
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(artist.name)
                .font(LDFont.heading04)
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

#Preview {
    ArticleListView(selectedExhibitionId: 1)
        .environmentObject(NavigationRouter())
}
