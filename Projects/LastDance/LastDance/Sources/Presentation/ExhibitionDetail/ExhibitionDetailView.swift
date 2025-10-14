//
//  ExhibitionDetailView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct ExhibitionDetailView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ExhibitionDetailViewModel()

    let exhibitionId: String
    @State private var exhibition: Exhibition?

    var body: some View {
        VStack(spacing: 0) {
            if let exhibition = exhibition {
                ScrollView {
                    VStack(spacing: 0) {
                        ExhibitionImageSection(coverImageName: exhibition.coverImageName)

                        ExhibitionInfoSection(exhibition: exhibition)
                    }
                }

                Spacer()

                ViewButton
            } else {
                Text("전시 정보를 불러올 수 없습니다")
                    .foregroundStyle(.gray)
                    .padding(.top, 100)
            }
        }
        .navigationTitle("전시정보")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            fetchExhibition()
        }
    }

    var ViewButton: some View {
        BottomButton(text: "관람하기") {
            // TODO: 다음 화면으로 네비게이션
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
    }

    private func fetchExhibition() {
        // TODO: ExhibitionListView에서 선택한 전시 데이터 연결 필요
        // SwiftDataManager.fetchById 사용 시 predicate 오류 발생
        // 임시로 fetchAll 후 필터링 또는 다른 방식으로 데이터 전달 필요
        let dataManager = SwiftDataManager.shared
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        exhibition = allExhibitions.first { $0.id == exhibitionId }
    }
}

/// 전시 커버 이미지 섹션
struct ExhibitionImageSection: View {
    let coverImageName: String?

    var body: some View {
        if let imageName = coverImageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 400)
                .overlay(
                    Text("이미지 없음")
                        .foregroundStyle(.gray)
                )
        }
    }
}

/// 전시 정보 섹션
struct ExhibitionInfoSection: View {
    let exhibition: Exhibition
    @State private var artistNames: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exhibition.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.black)

            if !artistNames.isEmpty {
                Text(artistNames.joined(separator: ", "))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.black)
            }

            Text(formatDateRange(start: exhibition.startDate, end: exhibition.endDate))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .task {
            fetchArtistNames()
        }
    }

    private func fetchArtistNames() {
        let dataManager = SwiftDataManager.shared
        let allArtists = dataManager.fetchAll(Artist.self)

        // exhibition의 artworks에서 artistId를 가져와서 작가 이름 매칭
        let artistIds = exhibition.artworks.compactMap { $0.artistId }
        artistNames = allArtists
            .filter { artistIds.contains($0.id) }
            .map { $0.name }
    }

    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일(E)~ yyyy년 M월 d일(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: start) + " ~ " + formatter.string(from: end)
    }
}

#Preview {
    ExhibitionDetailView(exhibitionId: "exhibition_light")
        .environmentObject(NavigationRouter())
}
