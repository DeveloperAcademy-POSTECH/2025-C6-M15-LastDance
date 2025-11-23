//
//  AudienceArchivingView.swift
//  LastDance
//
//  Created by donghee, 광로 on 10/19/25.
//

import SwiftUI

struct AudienceArchivingView: View {
    @StateObject private var viewModel = ArchivingViewModel()
    @EnvironmentObject private var router: NavigationRouter
    @State private var isBottomButtonVisible: Bool = true

    private let gridColumns: [GridItem] = [
        GridItem(.fixed(155), spacing: 16),
        GridItem(.fixed(155), spacing: 16),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationHeader()

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.hasExhibitions {
                // 전시 그리드
                ScrollView {
                    LazyVGrid(
                        columns: gridColumns,
                        alignment: .leading,
                        spacing: 24
                    ) {
                        ForEach(Array(viewModel.exhibitions.enumerated()), id: \.element.id) {
                            index, exhibition in
                            ExhibitionCardView(
                                exhibition: exhibition,
                                dateString: viewModel.dateString(for: exhibition)
                            )
                            .offset(y: index % 2 == 0 ? 0 : 40)
                            .onTapGesture {
                                router.push(.exhibitionArchive(exhibitionId: exhibition.id))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .padding(.bottom, 100)
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { oldOffset, newOffset in
                    guard viewModel.hasExhibitions else { return }

                    let delta = newOffset - oldOffset

                    // 너무 미세한 떨림은 무시
                    guard abs(delta) > 0.5 else { return }

                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        if delta > 0 {
                            isBottomButtonVisible = true
                        } else {
                            isBottomButtonVisible = false
                        }
                    }
                }
            } else {
                // 빈 상태
                VStack(spacing: 24) {
                    Image("emptyArchiveImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 286)

                    Text("전시 관람을 시작해\n나만의 전시 보관소를 만들어보세요")
                        .font(LDFont.medium01)
                        .foregroundColor(LDColor.color1)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .offset(y: -54)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white)
        .overlay(alignment: .bottomTrailing) {
            BottomButton(
                text: "촬영하기",
                isEnabled: true
            ) {
                router.push(.camera)
            }
            .modifier(
                BottomButtonVisibilityModifier(
                    isVisible: viewModel.hasExhibitions ? isBottomButtonVisible : true
                ))
        }
        .onAppear {
            viewModel.loadExhibitions()
        }
    }
}

// MARK: - 버튼 자연스럽게 등장/퇴장하기 위한 Modifier
private struct BottomButtonVisibilityModifier: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .offset(y: isVisible ? 0 : 120)
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
            .animation(.spring(response: 0.9, dampingFraction: 0.9), value: isVisible)
    }
}

// MARK: - Components

struct ExhibitionCardView: View {
    let exhibition: Exhibition
    let dateString: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 전시 포스터 이미지
            if let coverImageURLString = exhibition.coverImageName,
                let coverImageURL = URL(string: coverImageURLString)
            {
                AsyncImage(url: coverImageURL) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 155, height: 219)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 155, height: 219)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 155, height: 219)
                            .overlay(
                                Image(systemName: "PlaceholderImage")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 155, height: 219)
                    .overlay(
                        Text("이미지 없음")
                            .foregroundColor(.gray)
                    )
            }
            // 전시 제목
            Text(exhibition.title)
                .font(LDFont.heading06)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 155, alignment: .leading)

            // 날짜
            Text(dateString)
                .font(LDFont.regular03)
                .foregroundColor(LDColor.gray5)
                .frame(width: 155, alignment: .leading)
        }
    }
}

#Preview {
    AudienceArchivingView()
        .environmentObject(NavigationRouter())
}
