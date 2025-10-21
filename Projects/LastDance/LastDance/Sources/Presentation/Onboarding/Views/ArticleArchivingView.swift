//
//  ArchivingView.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

struct ArticleArchivingTitleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("나의 전시")
                .font(LDFont.heading02)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 20)
        .padding(.leading, 20)
    }
}

struct ArticleArchivingAddButtonSection: View {
    @EnvironmentObject private var router: NavigationRouter
    
    let viewModel: ArchivingViewModel

    var body: some View {
        VStack(spacing: 40) {
            CircleAddButton {
                router.push(.articleExhibitionList)
            }

            Text("나의 작품에 어떤 반응을\n 남겼는지 확인해보세요")
                .font(LDFont.medium01)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

/// 아카이빙 시작 뷰
struct ArticleArchivingView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArchivingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ArticleArchivingTitleSection()
            Spacer()

            ArticleArchivingAddButtonSection(viewModel: viewModel)

            Spacer()
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            // TODO: - Artist 전체 목록 가져오기 확인용 (나중에 제거)
            viewModel.loadAllArtists()
        }
    }
}

#Preview {
    ArticleArchivingView()
}
