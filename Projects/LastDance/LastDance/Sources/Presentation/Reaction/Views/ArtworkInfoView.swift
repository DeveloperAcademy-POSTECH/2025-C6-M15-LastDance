import SwiftData
import SwiftUI

struct ArtworkInfoView: View {
    let artworkId: Int
    let capturedImage: UIImage?

    @Query private var allArtworks: [Artwork]
    @Query private var allArtists: [Artist]

    private var artwork: Artwork? {
        allArtworks.first { $0.id == artworkId }
    }

    private var artist: Artist? {
        guard let artistId = artwork?.artistId else { return nil }
        return allArtists.first { $0.id == artistId }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 이미지 표시 로직
            if let capturedImage = capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 373)
                    .clipped()
            } else if let thumbnailURLString = artwork?.thumbnailURL,
                      let thumbnailURL = URL(string: thumbnailURLString) {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxHeight: 373)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 373)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxHeight: 373)
                            .overlay(
                                Image(systemName: "PlaceholderImage")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 343)
                    .overlay(
                        Text("이미지 없음")
                            .foregroundColor(.gray)
                    )
            }

            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    LDColor.color5.opacity(0),
                    LDColor.color5,
                ]),
                startPoint: .center,
                endPoint: .bottom
            )

            // 작품 정보 영역
            VStack(alignment: .leading, spacing: 8) {
                Text(artwork?.title ?? "작품 제목")
                    .font(LDFont.heading01)
                    .foregroundColor(LDColor.gray7)

                Text(artist?.name ?? "알 수 없는 작가")
                    .font(LDFont.medium02)
                    .foregroundColor(LDColor.gray7)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}
