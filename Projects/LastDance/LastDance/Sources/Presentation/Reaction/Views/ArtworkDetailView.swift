//
//  ArtworkDetailView.swift
//  LastDance
//
//  Created by 신얀 on 10/10/25.
//

import SwiftData
import SwiftUI

struct ArtworkDetailView: View {
    @Environment(\.keyboardManager) var keyboardManager
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ReactionInputViewModel()

    let artworkId: String
    @Query private var allArtworks: [Artwork]
    @Query private var allArtists: [Artist]

    private let placeholder = "욕설, 비속어 사용 시 전송이 제한될 수 있습니다."

    init(artworkId: String) {
        self.artworkId = artworkId
    }

    private var artwork: Artwork? {
        allArtworks.first { $0.id == artworkId }
    }

    private var artist: Artist? {
        guard let artistId = artwork?.artistId else { return nil }
        return allArtists.first { $0.id == artistId }
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    if let thumbnailURL = artwork?.thumbnailURL,
                        thumbnailURL.hasPrefix("http")
                    {
                        // 실제 URL인 경우
                        AsyncImage(url: URL(string: thumbnailURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                        }
                        .frame(maxHeight: 200)
                    } else if let imageName = artwork?.thumbnailURL {
                        // Mock 데이터
                        if UIImage(named: imageName) != nil {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                        } else {
                            // Mock 이미지가 없는 경우
                            Image(systemName: "photo.artframe")
                                .foregroundColor(.gray)
                                .frame(height: 200)
                        }
                    } else {
                        // thumbnailURL이 없는 경우
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                    }

                    Spacer().frame(height: 73)

                    VStack(alignment: .leading) {

                        Text(artwork?.title ?? "작품 제목")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer().frame(height: 17)

                        Text(artist?.name ?? "알 수 없는 작가")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer().frame(height: 43)

                        Text("반응 남기기")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer().frame(height: 20)

                        CategoryTag

                        Spacer().frame(height: 27)

                        MessageEditor

                    }
                    .padding(.horizontal, 10)

                    Spacer()

                }
                .padding(.horizontal, 20)
                .padding(.bottom, keyboardManager.keyboardHeight)
            }
            
            BottomButton(
                text: "전송하기",
                isEnabled: !viewModel.isSendButtonDisabled,
                action: {
                    viewModel.saveReaction(artworkId: artworkId, context: context)
                }
            )
        }
        .onAppear {
            if let savedCategories = UserDefaults.standard.array(forKey: "selectedCategories") as? [String] {
                viewModel.selectedCategories = Set(savedCategories)
            }
            Log.debug("[ArtworkDetailView]: \(viewModel.selectedCategories)")
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .navigationBarTitle("반응 남기기", displayMode: .inline)
        .animation(
            .easeOut(duration: 0.25),
            value: keyboardManager.keyboardHeight
        )
    }

    @ViewBuilder
    private var CategoryTag: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("태그*")

            HStack {
                Text(
                    Array(viewModel.selectedCategories).joined(
                        separator: ", "
                    )
                )
                .foregroundColor(.black)
            }
        }
    }

    @ViewBuilder
    private var MessageEditor: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("메시지")

            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {

                    Rectangle()
                        .fill(Color.white)
                        .frame(minHeight: 100, maxHeight: 152)
                        .cornerRadius(4)

                    if viewModel.message.isEmpty {
                        Text(placeholder)
                            .foregroundColor(
                                Color(red: 0.79, green: 0.79, blue: 0.79)
                            )
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $viewModel.message)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .tint(Color(red: 0.35, green: 0.35, blue: 0.35))
                        .padding(.top, 3)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                        .padding(.bottom, 10)
                        .frame(height: 152)
                        .onChange(of: viewModel.message) { newValue in
                            viewModel.updateMessage(newValue: newValue)
                        }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )

                Text("\(viewModel.message.count)/\(viewModel.limit)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

        }
    }
}

#Preview {
    ArtworkDetailView(artworkId: "artwork_light_01")
}
