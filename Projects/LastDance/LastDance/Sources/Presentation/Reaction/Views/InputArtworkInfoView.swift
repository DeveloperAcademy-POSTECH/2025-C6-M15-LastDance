//
//  InputArtworkInfoView.swift
//  LastDance
//
//  Created by 아우신얀 on 10/15/25.
//

import SwiftUI
import SwiftData

struct InputArtworkInfoView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ReactionInputViewModel()

    @State private var activeBottomSheet: BottomSheetType? = nil

    @Query private var artworks: [Artwork]
    @Query private var artists: [Artist]

    let image: UIImage
    let exhibitionId: Int?
    let artistId: Int?

    private var isBottomSheetActive: Bool {
        activeBottomSheet != nil
    }

    var body: some View {
            ZStack(alignment: .bottom) {
                VStack {
                    Spacer().frame(height: 24)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 311, height: 411)
                            .shadow(color: .black.opacity(0.24), radius: 6, x: 0, y: 0)
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 283, height: 386)
                            .clipped()
                    }

                    Spacer().frame(height: 36)

                    VStack(spacing: 12) {
                        InputFieldButton(
                            label: "제목",
                            value: viewModel.selectedArtworkTitle,
                            placeholder: "작품 제목을 선택해주세요",
                            action: { activeBottomSheet = .artwork }
                        )

                        InputFieldButton(
                            label: "작가",
                            value: viewModel.selectedArtistName,
                            placeholder: "작가명을 알려주세요",
                            action: { activeBottomSheet = .artist }
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    BottomButton(
                        text: "다음",
                        isEnabled: !viewModel.selectedArtworkTitle.isEmpty
                            && !viewModel.selectedArtistName.isEmpty,
                        action: {
                            // 선택한 작품 찾기
                            guard let selectedArtwork = artworks.first(where: { $0.title == viewModel.selectedArtworkTitle }) else {
                                Log.debug("선택한 작품을 찾을 수 없습니다: \(viewModel.selectedArtworkTitle)")
                                return
                            }

                            viewModel.setArtworkInfo(
                                artworkTitle: viewModel.selectedArtworkTitle,
                                artistName: viewModel.selectedArtistName,
                                artworkId: selectedArtwork.id
                            ) { success in
                                if success {
                                    router.push(.artworkDetail(id: selectedArtwork.id, capturedImage: image))
                                }
                            }
                        }
                    )
                    .padding(.bottom, 35)
                }
                .background(Color.white)

                if isBottomSheetActive {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .onTapGesture {
                            activeBottomSheet = nil
                        }
                }

                /// 작품 제목 바텀시트
                if activeBottomSheet == .artwork {
                    CustomBottomSheet(
                        Binding(
                            get: { activeBottomSheet == .artwork },
                            set: { if !$0 { activeBottomSheet = nil } }
                        ),
                        height: 393
                    ) {
                        SelectionSheet(
                            title: "제목",
                            items: artworks.map { $0.title },
                            selectedItem: $viewModel.selectedArtworkTitle,
                            onDismiss: { activeBottomSheet = nil }
                        )
                    }
                    .onAppear {
                        viewModel.fetchArtworks(artistId: artistId, exhibitionId: exhibitionId)
                    }
                }

                /// 작가 바텀시트
                if activeBottomSheet == .artist {
                    CustomBottomSheet(
                        Binding(
                            get: { activeBottomSheet == .artist },
                            set: { if !$0 { activeBottomSheet = nil } }
                        ),
                        height: 393
                    ) {
                        SelectionSheet(
                            title: "작가",
                            items: artists.map { $0.name },
                            selectedItem: $viewModel.selectedArtistName,
                            onDismiss: { activeBottomSheet = nil }
                        )
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - InputFieldButton
private struct InputFieldButton: View {
    let label: String
    let value: String
    let placeholder: String
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Text(label)
                    .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.35))
                Spacer()

                Text(value.isEmpty ? placeholder : value)
                    .foregroundColor(
                        value.isEmpty
                            ? Color(red: 0.66, green: 0.66, blue: 0.66)
                            : .primary
                    )
            }
            .frame(minHeight: 60)
        }
        .padding(.horizontal, 14)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .cornerRadius(12)
    }
}

// MARK: - SelectionSheet
private struct SelectionSheet: View {
    let title: String
    let items: [String]
    @Binding var selectedItem: String
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .padding(.top, 10)
                .padding(.horizontal, 24)

            Spacer().frame(height: 24)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            HStack {
                                Text(item)
                                    .foregroundColor(.black)
                                    .font(Font.custom("SF Pro Text", size: 17))
                                Spacer()
                            }
                            .padding(12)
                            .frame(height: 44)
                        }
                        .background(selectedItem == item ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color.clear)
                        .cornerRadius(12)
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.horizontal, 12)

            BottomButton(text: "완료", action: onDismiss)
                .padding(.bottom, 35)
        }
    }
}
