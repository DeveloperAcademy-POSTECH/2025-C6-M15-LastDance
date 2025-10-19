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
                .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.52))
                .padding(.top, 24)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
    }
}

struct ExhibitionListContent: View {
    @ObservedObject var viewModel: ExhibitionListViewModel
    
    let exhibitions: [Exhibition]

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
            .padding(.horizontal, 20)
        }
    }
}

struct ExhibitionListRegisterButton: View {
    @EnvironmentObject private var router: NavigationRouter
    @ObservedObject var viewModel: ExhibitionListViewModel

    var body: some View {
        BottomButton(
            text: "등록하기",
            isEnabled: viewModel.selectedExhibitionId != nil
        ) {
            if let exhibitionId = viewModel.selectedExhibitionId {
                router.push(.exhibitionDetail(id: exhibitionId))
            }
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

            ExhibitionListContent(viewModel: viewModel, exhibitions: exhibitions)

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
            viewModel.getExhibitions()
        }
    }
}

#Preview {
    ExhibitionListView()
}
