//
//  ExhibitionListView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI
import SwiftData

struct ExhibitionListTitleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("관람하려 온 전시를 알려주세요")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("전시명")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6))
                .padding(.top, 24)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
    }
}

struct ExhibitionListContent: View {
    let exhibitions: [Exhibition]
    @ObservedObject var viewModel: ExhibitionListViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(exhibitions, id: \.id) { exhibition in
                    SelectionRow(
                        title: exhibition.title,
                        isSelected: viewModel.selectedExhibitionId == exhibition.id
                    ) {
                        viewModel.selectExhibition(exhibition)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ExhibitionListRegisterButton: View {
    @ObservedObject var viewModel: ExhibitionListViewModel

    var body: some View {
        BottomButton(text: "등록하기") {
            viewModel.tapRegisterButton()
        }
    }
}

struct ExhibitionListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ExhibitionListViewModel()
    @Query private var exhibitions: [Exhibition]

    private let dataManager = SwiftDataManager.shared

    var body: some View {
        VStack(spacing: 0) {
            ExhibitionListTitleSection()

            ExhibitionListContent(exhibitions: exhibitions, viewModel: viewModel)

            Spacer()

            ExhibitionListRegisterButton(viewModel: viewModel)
        }
        .padding(.top, 18)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomNavigationBar(title: "전시찾기") {
                router.popLast()
            }
        }
        .onAppear {
//            viewModel.getExhibitions()

            // 전시 생성 API 테스트
            testMakeExhibition()
        }
    }

    // MARK: - API Test Helper
    private func testMakeExhibition() {
        // SwiftDataManager에서 저장된 Artist 데이터 가져오기
        let artists = dataManager.fetchAll(Artist.self)
        guard let firstArtist = artists.first else {
            Log.error("[ExhibitionListView] SwiftData에 Artist 데이터가 없습니다.")
            return
        }

        // 전시 생성 API 호출 (ViewModel의 makeExhibitionList 메서드 사용)
        viewModel.makeExhibitionList()
        Log.debug("[ExhibitionListView] 전시 생성 API 테스트 실행 (Artist ID: \(firstArtist.id), Name: \(firstArtist.name))")
    }
}

#Preview {
    ExhibitionListView()
}
