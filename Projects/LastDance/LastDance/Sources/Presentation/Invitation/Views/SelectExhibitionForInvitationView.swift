//
//  SelectExhibitionForInvitationView.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import SwiftUI

struct SelectExhibitionForInvitationView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = SelectExhibitionViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ExhibitionSelectionGridView(viewModel: viewModel)
            }
        }
        .background(LDColor.color6)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomNavigationBarWithAction(
                title: "전시 초대하기",
                actionTitle: "초대",
                isActionEnabled: viewModel.isInviteEnabled,
                onBackButtonTap: {
                    router.popLast()
                },
                onActionTap: {
                    if let exhibition = viewModel.getSelectedExhibition() {
                        router.push(.invitationDetail(exhibition: exhibition))
                    }
                }
            )
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.loadActiveExhibitions()
        }
    }
}

private struct ExhibitionSelectionGridView: View {
    @ObservedObject var viewModel: SelectExhibitionViewModel

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.fixed(155), spacing: 31),
                    GridItem(.fixed(155), spacing: 31),
                ],
                spacing: 28
            ) {
                ForEach(viewModel.exhibitions, id: \.id) { exhibition in
                    ExhibitionSelectionCardView(
                        exhibition: exhibition,
                        isSelected: viewModel.selectedExhibition?.id == exhibition.id
                    )
                    .onTapGesture {
                        viewModel.selectExhibition(exhibition)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 30)
            .padding(.bottom, 100)
        }
    }
}

private struct ExhibitionSelectionCardView: View {
    let exhibition: Exhibition
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // 전시 이미지
                if let coverImageURLString = exhibition.coverImageName {
                    CachedImage(coverImageURLString)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 155, height: 219)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 155, height: 219)
                        .overlay(
                            Text("이미지 없음")
                                .foregroundColor(.gray)
                        )
                }

                // 선택 표시 (항상 표시)
                Circle()
                    .fill(isSelected ? LDColor.color1 : Color.clear)
                    .frame(width: 25, height: 25)
                    .overlay(
                        Circle()
                            .stroke(LDColor.color6, lineWidth: 2)
                    )
                    .overlay(
                        Group {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    )
                    .padding(.trailing, 12)
                    .padding(.top, 12)
            }

            // 전시 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(exhibition.title)
                    .font(LDFont.medium04)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: 155, alignment: .topLeading)

                Text(
                    Date.formatShortDateRange(start: exhibition.startDate, end: exhibition.endDate)
                )
                .font(LDFont.regular03)
                .foregroundColor(LDColor.color2)
            }
        }
    }
}

#Preview {
    SelectExhibitionForInvitationView()
        .environmentObject(NavigationRouter())
}
