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

    private let gridColumns: [GridItem] = [
        GridItem(.fixed(155), spacing: 16),
        GridItem(.fixed(155), spacing: 16),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("나의 전시")
                .font(LDFont.heading02)
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.top, 20)

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.hasExhibitions {
                // 전시 그리드
                ScrollView {
                    LazyVGrid(
                        columns: gridColumns,
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
                    .padding(.horizontal, 32)
                    .padding(.top, 30)
                    .padding(.bottom, 100)
                }
            } else {
                // 빈 상태
                VStack(spacing: 38) {
                    CircleAddButton {
                        router.push(.exhibitionList)
                    }
                    Text("전시 관람을 시작해 나만의\n전시 보관소를 만들어보세요")
                        .font(LDFont.medium03)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white)
        .overlay(alignment: .bottomTrailing) {
            // 플로팅 버튼 (전시가 있을 때만)
            if viewModel.hasExhibitions {
                CircleAddButton {
                    router.push(.exhibitionList)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.loadExhibitions()
        }
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
                    case let .success(image):
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
