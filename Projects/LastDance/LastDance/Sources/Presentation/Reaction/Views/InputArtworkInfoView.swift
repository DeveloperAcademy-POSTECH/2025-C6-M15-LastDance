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

    @State private var showArtworkBottomSheet: Bool = false  // 작품 바텀시트의 상태를 알려주는 변수
    @State private var showArtistBottomSheet: Bool = false  // 작가 바텀시트의 상태를 알려주는 변수
    @State private var selectedTitle: String = ""
    @State private var selectedArtist: String = ""

    @Query(filter: #Predicate<Artwork> { $0.artistId == "artist_kim" })
    private var kimArtworks: [Artwork]

    @Query private var artists: [Artist]

    let image: UIImage
    var activeBtn: Bool = false  // 하단 버튼 활성화를 알려주는 변수

    var body: some View {

        GeometryReader { geo in
            let cardW = geo.size.width * CameraViewLayout.confirmCardWidthRatio
            let cardH = cardW / CameraViewLayout.aspect
            ZStack(alignment: .bottom) {
                Color(.blue).ignoresSafeArea()

                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardW, height: cardH)
                        .clipped()

                    Spacer().frame(height: 20)

                    VStack(spacing: 12) {
                        InputFieldButton(
                            label: "제목",
                            value: selectedTitle,
                            placeholder: "작품 제목을 선택해주세요",
                            action: { showArtworkBottomSheet = true }
                        )
                        
                        InputFieldButton(
                            label: "작가",
                            value: selectedArtist,
                            placeholder: "작가명을 알려주세요",
                            action: { showArtistBottomSheet = true }
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    BottomButton(
                        text: "다음",
                        isEnabled: !selectedTitle.isEmpty
                            && !selectedArtist.isEmpty,
                        action: {
                            router.push(.category)
                        }
                    )
                    .padding(.bottom, 35)
                }
                
                /// 작품 제목 바텀시트
                if showArtworkBottomSheet {
                    CustomBottomSheet($showArtworkBottomSheet, height: 393) {
                        SelectionSheet(
                            title: "제목",
                            items: kimArtworks.map { $0.title },
                            selectedItem: $selectedTitle,
                            showBottomSheet: $showArtworkBottomSheet
                        )
                    }
                    .onAppear {
                        Log.debug("Kim Artworks count: \(kimArtworks.count)")
                        kimArtworks.forEach { artwork in
                            Log.debug("Artwork: \(artwork.title) (artistId: \(artwork.artistId))")
                        }
                    }
                }

                /// 작가 바텀시트
                if showArtistBottomSheet {
                    CustomBottomSheet($showArtistBottomSheet, height: 393) {
                        SelectionSheet(
                            title: "작가",
                            items: artists.map { $0.name },
                            selectedItem: $selectedArtist,
                            showBottomSheet: $showArtistBottomSheet
                        )
                    }
                    .onAppear {
                        Log.debug("Artists count: \(artists.count)")
                        artists.forEach { artist in
                            Log.debug("Artist: \(artist.name) (id: \(artist.id))")
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .animation(.interactiveSpring(), value: showArtistBottomSheet || showArtworkBottomSheet)
        .onAppear {
            Log.debug("InputArtworkInfoView appeared")
            Log.debug("Initial kimArtworks count: \(kimArtworks.count)")
            Log.debug("Initial artists count: \(artists.count)")
        }
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
                    .padding(.horizontal, 12)
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
        .padding(.horizontal, 12)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
    }
}

// MARK: - SelectionSheet
private struct SelectionSheet: View {
    let title: String
    let items: [String]
    @Binding var selectedItem: String
    @Binding var showBottomSheet: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .padding(.top, 22)
                .padding(.horizontal, 34)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            HStack {
                                Text(item)
                                    .foregroundColor(!selectedItem.isEmpty ? Color(red: 0.94, green: 0.94, blue: 0.94) : .white)
                                Spacer()
                            }
                            .padding()
                        }
                        .background(selectedItem == item ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color.clear)
                        .padding(.bottom, 12)
                    }
                }
            }
            .padding(.horizontal, 12)

            BottomButton(text: "완료", action: {
                showBottomSheet = false
            })
            .padding(.bottom, 35)
        }
//        .presentationDetents([.medium, .large])
    }
}
