//
//  ArticleListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

struct ArticleListSearchTextField: View {
    @ObservedObject var viewModel: ArticleListViewModel
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        TextField(
            "작가명을 검색해주세요",
            text: $viewModel.searchText
        )
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
        .padding(.horizontal, 20)
        .focused($isFocused)
        .onSubmit {
            // 엔터를 눌렀을 때 필터링된 작가 중 첫 번째 항목 선택
            if let firstArtist = viewModel.filteredArtists.first {
                viewModel.selectArtist(firstArtist)
                viewModel.searchText = firstArtist.name
                isFocused = false
            }
        }
        .onChange(of: viewModel.searchText) { newValue in
            if !newValue.isEmpty {
                isFocused = true
            }
            // 텍스트가 변경되면 선택된 작가 초기화
            if viewModel.selectedArtistName != newValue {
                viewModel.selectedArtistId = nil
                viewModel.selectedArtistName = ""
            }
        }
    }
}

struct ArticleListContent: View {
    @ObservedObject var viewModel: ArticleListViewModel
    @FocusState.Binding var isFocused: Bool

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
        if isFocused && !viewModel.searchText.isEmpty {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredArtists, id: \.id) { artist in
                        ArticleArtistRow(
                            artist: artist,
                            isSelected: viewModel.selectedArtistId == artist.id
                        ) {
                            viewModel.selectArtist(artist)
                            viewModel.searchText = artist.name
                            isFocused = false
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(height: 337)
            .background(backgroundShape)
            .overlay(borderShape)
            .padding(.horizontal, 20)
            .scrollToMinDistance(minDisntance: 32)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

struct ArticleListNextButton: View {
    @EnvironmentObject private var router: NavigationRouter
    let selectedExhibitionId: Int
    @ObservedObject var viewModel: ArticleListViewModel

    var body: some View {
        BottomButton(
            text: "다음",
            isEnabled: viewModel.selectedArtistId != nil
        ) {
            if let artistId = viewModel.tapNextButton() {
                router.push(.completeArticleList(selectedExhibitionId: selectedExhibitionId, selectedArtistId: artistId))
            }
        }
    }
}

/// 작가 플로우에서 작가 선택 뷰
struct ArticleListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArticleListViewModel()
    @FocusState private var isFocused: Bool

    let selectedExhibitionId: Int

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                PageIndicator(totalPages: 2, currentPage: 1)

                TitleSection(title: "어떤 작가님이신가요?", subtitle: "작가명")

                ArticleListSearchTextField(viewModel: viewModel, isFocused: $isFocused)

                ArticleListContent(viewModel: viewModel, isFocused: $isFocused)

                Spacer()

                ArticleListNextButton(
                    selectedExhibitionId: selectedExhibitionId,
                    viewModel: viewModel
                )
            }
            .padding(.top, 18)
            .toolbar {
                CustomNavigationBar(title: "전시찾기") {
                    router.popLast()
                }
            }
            .onTapGesture {
                isFocused = false
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
                        .fill(isSelected ? LDColor.gray3 : Color.clear)
                )
                .padding(.horizontal, isSelected ? 8 : 0)
        }
    }
}
