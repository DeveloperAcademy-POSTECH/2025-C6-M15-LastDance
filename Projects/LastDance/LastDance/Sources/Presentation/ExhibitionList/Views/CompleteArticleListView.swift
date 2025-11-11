//
//  CompleteArticleListView.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

//MARK: - CompleteArticleListInfoView
struct CompleteArticleListInfoView: View {
  @ObservedObject var viewModel: CompleteArticleListViewModel  // 주입받음

  var body: some View {
    VStack(spacing: 28) {
      InfoRow(label: "작가명", value: viewModel.artist?.name ?? "")
      InfoRow(label: "전시명", value: viewModel.exhibition?.title ?? "")
    }
    .padding(.horizontal, 20)
  }
}

struct CompleteArticleListFindButtonView: View {
  @EnvironmentObject private var router: NavigationRouter
  @ObservedObject var viewModel: CompleteArticleListViewModel
  @Binding var showNotFoundAlert: Bool

  var body: some View {
    BottomButton(text: "전시 찾기") {
      viewModel.saveCurrentArtistAsUser()
      if let id = viewModel.exhibition?.id {
        // 전시 상세로 이동
        router.push(.exhibitionDetail(id: id))
      } else {
        showNotFoundAlert = true
      }
    }
  }
}

struct CompleteArticleListView: View {
  @EnvironmentObject private var router: NavigationRouter
  @StateObject private var viewModel = CompleteArticleListViewModel()  //최상위 위치
  @State private var showNotFoundAlert = false

  let selectedExhibitionId: Int
  let selectedArtistId: Int

  var body: some View {
    VStack(spacing: 0) {
      PageIndicator(totalPages: 2, currentPage: 2)

      TitleSection(title: "어떤 작가님이신가요?", subtitle: nil)

      CompleteArticleListInfoView(viewModel: viewModel)  //실제 주입
        .padding(.top, 14)

      Spacer()

      CompleteArticleListFindButtonView(viewModel: viewModel, showNotFoundAlert: $showNotFoundAlert)
    }
    .padding(.top, 18)
    .padding(.bottom, 34)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      CustomNavigationBar(title: "전시찾기") {
        router.popLast()
      }
    }
    .customAlert(
      isPresented: $showNotFoundAlert,
      image: "warning",
      title: "아쉬워요!",
      message: "전시 정보를 불러오지 못했어요.\n전시 정보를 다시 확인해 주세요.",
      buttonText: "다시 찾기",
      action: {
        showNotFoundAlert = false
      }
    )
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
        .font(LDFont.regular02)
        .foregroundStyle(.black)

      Text(value)
        .font(LDFont.regular01)
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(LDColor.gray3)
        )
    }
  }
}
