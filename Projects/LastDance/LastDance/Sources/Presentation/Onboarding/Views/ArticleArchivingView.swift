//
//  ArticleArchivingView.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

struct ArtistExhibitionCardView: View {
    let displayItem: ArtistExhibitionDisplayItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .bottomLeading) {
                CachedImage(
                    displayItem.exhibition.coverImageName,
                    targetSize: CGSize(width: 167, height: 227)
                )
                .aspectRatio(contentMode: .fill)
                .frame(width: 167, height: 227)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 4)
            }

            Text(displayItem.exhibition.title)
                .font(LDFont.medium04)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 167, alignment: .topLeading)

            // 날짜
            Text(Date.formatShortDate(from: displayItem.exhibition.startDate))
                .font(LDFont.regular03)
                .foregroundColor(LDColor.gray5)
                .frame(width: 167, alignment: .leading)
        }
    }
}

private struct ArtistExhibitionGridView: View {
    @ObservedObject var viewModel: ArtistReactionViewModel
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.fixed(167), spacing: 19),
                    GridItem(.fixed(167)),
                ],
                spacing: 48
            ) {
                ForEach(Array(viewModel.exhibitions.enumerated()), id: \.element.id) {
                    index, displayItem in
                    ArtistExhibitionCardView(
                        displayItem: displayItem
                    )
                    .offset(y: index % 2 == 0 ? 0 : 40)
                    .onTapGesture {
                        router.push(
                            .artistReactionArchiveView(
                                exhibitionId: displayItem.exhibition.id
                            )
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 100)
        }
    }
}

/// 아카이빙 시작 뷰
struct ArticleArchivingView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArtistReactionViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("exhibition_title")
                    .font(LDFont.heading02)
                    .foregroundColor(.black)

                Spacer()

                // 전시가 있을 때만 알림과 초대장 버튼 표시
                if !viewModel.isLoading && !viewModel.exhibitions.isEmpty {
                    Button(action: {
                        router.push(.alarmList(userType: .artist))
                    }) {
                        Image("bell")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.leading, 14)

                    Button(action: {
                        router.push(.createInvitation)
                    }) {
                        Image("envelope.noti")
                            .resizable()
                            .frame(width: 22, height: 19)
                    }
                    .padding(.leading, 14)
                }
            }
            .foregroundColor(.black)
            .padding(.top, 20)
            .padding(.horizontal, 24)

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ArtistExhibitionGridView(viewModel: viewModel)
            }
        }
        .background(LDColor.color6)
        .onAppear {
            Log.debug("📱 ArticleArchivingView appeared")
            viewModel.loadArtistExhibitions()
        }
        .onChange(of: viewModel.isLoading) { newValue in
            Log.debug("🔄 isLoading 변경됨: \(newValue)")
            if !newValue {
                Log.debug("🔄 로딩 완료 후 exhibitions.count: \(viewModel.exhibitions.count)")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ArticleArchivingView()
}
