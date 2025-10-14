//
//  ArticleExhibitionListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

struct ArticleExhibitionListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArticleExhibitionListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            PageIndicator(totalPages: 2, currentPage: 1)
                .padding(.horizontal, -20)

            TitleSection

            ExhibitionList

            Spacer()

            NextButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
        .navigationBarBackButtonHidden(false)
        .navigationTitle("전시찾기")
        .navigationBarTitleDisplayMode(.inline)
    }

    var TitleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("참여한 전시를 알려주세요")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("전시명")
                .font(Font.custom("Pretendard", size: 16))
                .foregroundStyle(Color.black)
                .padding(.top, 24)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    var ExhibitionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.exhibitions, id: \.id) { exhibition in
                    ArticleExhibitionRow(
                        exhibition: exhibition,
                        isSelected: viewModel.selectedExhibitionId == exhibition.id
                    ) {
                        viewModel.selectExhibition(exhibition)
                    }
                }
            }
        }
    }

    var NextButton: some View {
        BottomButton(text: "다음") {
            if let exhibitionId = viewModel.tapNextButton() {
                router.push(.articleList(selectedExhibitionId: exhibitionId))
            }
        }
    }
}

/// 전시 목록 행 컴포넌트
struct ArticleExhibitionRow: View {
    let exhibition: Exhibition
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(exhibition.title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 1)
                        .stroke(isSelected ? Color.black : Color.black.opacity(0.14), lineWidth: isSelected ? 2 : 1)
                )
        }
        .padding(.bottom, 8)
    }
}
#Preview {
    ArticleExhibitionListView()
        .environmentObject(NavigationRouter())
}
