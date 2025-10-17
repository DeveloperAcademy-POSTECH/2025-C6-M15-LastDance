//
//  CompleteArticleListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

//MARK: - CompleteArticleListInfoView
struct CompleteArticleListInfoView: View {
    @ObservedObject var viewModel: CompleteArticleListViewModel       // 주입받음

    var body: some View {
        VStack(spacing: 28) {
            InfoRow(label: "작가명", value: viewModel.artist?.name ?? "")
            InfoRow(label: "전시명", value: viewModel.exhibition?.title ?? "")
        }
    }
}

struct CompleteArticleListFindButtonView: View {
    var body: some View {
        BottomButton(text: "전시 찾기") {
            // TODO: 전시 찾기 기능
        }
    }
}

struct CompleteArticleListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = CompleteArticleListViewModel() //최상위 위치

    let selectedExhibitionId: String
    let selectedArtistId: String

    var body: some View {
        VStack(spacing: 0) {
            PageIndicator(totalPages: 2, currentPage: 2)
                .padding(.horizontal, -28)
            TitleSection(title: "어떤 작가님이신가요?", subtitle: nil)
                .padding(.bottom, 8)
                .padding(.top, 14)
            CompleteArticleListInfoView(viewModel: viewModel)   //실제 주입
                .padding(.top, 14)
            Spacer()
            CompleteArticleListFindButtonView()
        }
        .padding(.top, 18)
        .padding(.horizontal, 28)
        .padding(.bottom, 34)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomNavigationBar(title: "전시찾기") {
                router.popLast()
            }
        }
        .task {
            viewModel.fetchData(exhibitionId: selectedExhibitionId, artistId: selectedArtistId)
        }
    }
}

/// 정보 표시 행
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Font.custom("Pretendard", size: 16))
                .foregroundStyle(.black)

            Text(value)
                .font(Font.custom("SF Pro Text", size: 17))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.94, green: 0.94, blue: 0.94))
                )
        }
    }
}

#Preview {
    CompleteArticleListView(
        selectedExhibitionId: "1",
        selectedArtistId: "1"
    )
    .environmentObject(NavigationRouter())
}
