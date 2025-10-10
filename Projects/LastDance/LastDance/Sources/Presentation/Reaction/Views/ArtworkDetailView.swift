//
//  ArtworkDetailView.swift
//  LastDance
//
//  Created by 신얀 on 10/10/25.
//

import SwiftUI
import SwiftData

struct ArtworkDetailView: View {
    @Environment(\.modelContext) private var context
    let artworkId: String
    @Query private var allArtworks: [Artwork]
    @Query private var allArtists: [Artist]
    @State private var message: String = ""  // 반응을 남기기 위한 textEditor 메세지

    private let placeholder = "욕설, 비속어 사용 시 전송이 제한될 수 있습니다."
    private let limit = 500
    
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
                       thumbnailURL.hasPrefix("http") {
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

                        Spacer().frame(height: 21)

                        MessageEditor

                    }
                    .padding(.horizontal, 10)

                    Spacer()

                }
                .padding(.horizontal, 20)
            }
            BottomButton
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("반응남기기", displayMode: .inline)
    }

    @ViewBuilder
    private var CategoryTag: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("태그")

            Button(
                action: {

                },
                label: {
                    ZStack {
                        Rectangle()
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: 46,
                                alignment: .leading
                            )
                            .foregroundStyle(.gray.opacity(0.1))
                        HStack {
                            Text("태그 선택하기")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 19)
                        }
                        .padding(10)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: 46,
                            alignment: .leading
                        )
                    }
                }
            )
        }
    }

    @ViewBuilder
    private var MessageEditor: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("메시지")

            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {

                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(minHeight: 100)
                        .cornerRadius(4)

                    if message.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.gray)
                            .padding(10)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $message)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 5)
                        .frame(minHeight: 100)
                        .onChange(of: message) { newValue in
                            if newValue.count > limit {
                                message = String(newValue.prefix(limit))
                            }
                        }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

                Text("\(message.count)/\(limit)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

        }
    }

    @ViewBuilder
    private var BottomButton: some View {
        Button(
            action: {
                saveReaction()
            },
            label: {
                HStack {
                    Text("전송하기")
                        .foregroundStyle(.black)
                }
            }
        )
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(.black, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 35)
    }
    
    /// 작품 반응을 저장하는 함수
    private func saveReaction() {
            guard message.isEmpty == false else { return }

            let reaction = Reaction(
                id: UUID().uuidString,
                artworkId: artwork?.id ?? "",
                userId: "mockUser", 
                category: ["감동"],
                comment: message,
                createdAt: .now
            )

            context.insert(reaction)

            do {
                try context.save()
                message = ""
                print("✅ Reaction saved successfully.")
            } catch {
                print("❌ Reaction save failed: \(error)")
            }
        }
}

#Preview {
    ArtworkDetailView(artworkId: "artwork_light_01")
}
