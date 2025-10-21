import SwiftUI
import SwiftData

struct ArtistReactionView: View {
    @StateObject private var viewModel = ArtistReactionViewModel() // ViewModel now fetches artist ID internally
    @EnvironmentObject private var router: NavigationRouter
    
    private let gridColumns: [GridItem] = [
        GridItem(.fixed(155), spacing: 16),
        GridItem(.fixed(155), spacing: 16)
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
            } else {
                // 그리드
                ScrollView {
                    LazyVGrid(
                        columns: gridColumns,
                        spacing: 24
                    ) {
                        ForEach(Array(viewModel.exhibitions.enumerated()), id: \.element.id) { index, displayItem in
                            ArtistExhibitionCard(
                                displayItem: displayItem // Pass the new display item
                            )
                            .onTapGesture {
                                router.push(.artistReactionArchiveView(exhibitionId: String(displayItem.exhibition.id)))
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 30)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(LDColor.color6)
        .overlay(alignment: .bottomTrailing) {
            // 플로팅 버튼
            CircleAddButton {
                router.push(.articleExhibitionList)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            viewModel.loadArtistExhibitions() // Call the new loading function
        }
    }
}

// MARK: - Components

struct ArtistExhibitionCard: View {
    let displayItem: ArtistExhibitionDisplayItem // Changed type
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 포스터 이미지 + 반응 카운터
            ZStack(alignment: .bottomLeading) {
                if let coverImageURLString = displayItem.exhibition.coverImageName,
                   let coverImageURL = URL(string: coverImageURLString) {
                    AsyncImage(url: coverImageURL) { phase in
                        switch phase {
                        case .empty:
                            // Placeholder while loading
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
                            // Placeholder on failure
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
                    // Fallback if coverImageName is nil or not a valid URL
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 155, height: 219)
                        .overlay(
                            Text("이미지 없음")
                                .foregroundColor(.gray)
                        )
                }
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("\(displayItem.reactionCount)")
                            .font(LDFont.heading07)
                            .foregroundColor(.white)
                    )
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
            }
            
            // 전시 제목 (고정 높이로 정렬 보장)
            Text(displayItem.exhibition.title)
                .font(LDFont.medium04)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 155, height: 44, alignment: .topLeading)
        }
    }
}
