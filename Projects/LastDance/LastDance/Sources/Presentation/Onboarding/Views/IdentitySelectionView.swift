//
//  IdentitySelectionView.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

/// 사용자 정체성 선택 뷰 (작가/관람객)
struct IdentitySelectionView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = IdentitySelectionViewModel()

    var body: some View {
        VStack(spacing: 28) {
            TitleSection

            Spacer()

            SelectionButtons

            Spacer()

            NextButton
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
    }

    var TitleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("어떤 방식으로 전시에 참여하고\n싶나요?")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 80)
    }
    
    var SelectionButtons: some View {
        VStack(spacing: 40) {

            CircleSelectionButton(
                title: UserType.artist.displayName,
                isSelected: viewModel.selectedType == .artist
            ) {
                viewModel.selectUserType(.artist)
            }

            CircleSelectionButton(
                title: UserType.viewer.displayName,
                isSelected: viewModel.selectedType == .viewer
            ) {
                viewModel.selectUserType(.viewer)
            }
            Spacer()
        }
    }

    var NextButton: some View {
        BottomButton(text: "다음") {
            viewModel.confirmSelection()
        }
    }
}
#Preview {
    IdentitySelectionView()
}
