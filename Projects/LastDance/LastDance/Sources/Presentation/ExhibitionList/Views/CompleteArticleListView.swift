//
//  CompleteArticleListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

struct CompleteArticleListView: View {
    @EnvironmentObject private var router: NavigationRouter

    let selectedExhibitionId: String
    let selectedArtistId: String

    @State private var exhibition: Exhibition?
    @State private var artist: Artist?

    var body: some View {
        VStack(spacing: 0) {
            PageIndicator(totalPages: 2, currentPage: 2)
                .padding(.horizontal, -28)
            TitleSection
                .padding(.top, 14)
            InfoSection
                .padding(.top, 14)
            Spacer()
            FindExhibitionButton
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 34)
        .navigationBarBackButtonHidden(false)
        .navigationTitle("전시찾기")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            fetchData()
        }
    }

    var TitleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("어떤 작가님이신가요?")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 20)
        .padding(.bottom, 24)
    }

    var InfoSection: some View {
        VStack(spacing: 28) {
            InfoRow(label: "작가명", value: artist?.name ?? "")
            InfoRow(label: "전시명", value: exhibition?.title ?? "")
        }
    }

    var FindExhibitionButton: some View {
        BottomButton(text: "전시 찾기") {
            // TODO: 전시 찾기 기능
        }
    }

    private func fetchData() {
        let dataManager = SwiftDataManager.shared
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        let allArtists = dataManager.fetchAll(Artist.self)

        exhibition = allExhibitions.first { $0.id == selectedExhibitionId }
        artist = allArtists.first { $0.id == selectedArtistId }
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
        selectedExhibitionId: "exhibition_light",
        selectedArtistId: "artist_kimjiin"
    )
    .environmentObject(NavigationRouter())
}
