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
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                CachedImage(
                    displayItem.exhibition.coverImageName,
                    targetSize: CGSize(width: 155, height: 219)  // targetSize는 이미지 로딩 최적화를 위함
                )
                .aspectRatio(contentMode: .fill)
                .frame(width: 155, height: 219)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text(displayItem.exhibition.title)
                .font(LDFont.medium04)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 155, height: 44, alignment: .topLeading)
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
                    GridItem(.fixed(155), spacing: 31),
                    GridItem(.fixed(155), spacing: 31),
                ],
                spacing: 28
            ) {
                ForEach(viewModel.exhibitions) { displayItem in
                    ArtistExhibitionCardView(
                        displayItem: displayItem
                    )
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
                Text("나의 전시")
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
                        Image(systemName: "envelope")
                            .resizable()
                            .frame(width: 28, height: 23)
                            .foregroundColor(.black)
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
