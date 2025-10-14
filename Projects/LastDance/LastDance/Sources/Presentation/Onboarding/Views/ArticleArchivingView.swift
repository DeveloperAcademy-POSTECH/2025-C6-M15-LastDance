//
//  ArchivingView.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

/// 아카이빙 시작 뷰
struct ArticleArchivingView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArchivingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            TitleSection
            Spacer()

            AddButtonSection

            Spacer()
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(false)
    }

    var TitleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("나의 전시")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 20)
        .padding(.leading, 20)
    }

    var AddButtonSection: some View {
        VStack(spacing: 40) {
            CircleAddButton {
                viewModel.tapAddButton()
            }

            Text("나의 작품에 어떤 반응을\n 남겼는지 확인해보세요")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}
#Preview {
    ArticleArchivingView()
}
