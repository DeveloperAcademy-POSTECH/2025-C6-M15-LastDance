//
//  RootView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = NavigationRouter()
    @State private var userType: UserType?

    init() {
        var initialUserType: UserType?
        if let userTypeValue = UserDefaults.standard.string(forKey: UserDefaultsKey.userType.key) {
            initialUserType = UserType(rawValue: userTypeValue)
        }
        _userType = State(initialValue: initialUserType)
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                // 테스트를 위해 CameraView를 첫 화면으로 설정
                CameraView()

//                if let userType = userType {
//                    switch userType {
//                    case .artist:
//                        ArticleArchivingView()
//                    case .viewer:
//                        AudienceArchivingView()
//                    }
//                } else {
//                    IdentitySelectionView()
//                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .identitySelection:
                    IdentitySelectionView()
                case .audienceArchiving:
                    AudienceArchivingView()
                        .toolbar(.hidden, for: .navigationBar)
                case .articleArchiving:
                    ArticleArchivingView()
                        .toolbar(.hidden, for: .navigationBar)
                case .exhibitionList:
                    ExhibitionListView()
                        .toolbar(.hidden, for: .navigationBar)
                case .exhibitionDetail(let id):
                    ExhibitionDetailView(exhibitionId: id)
                        .navigationBarBackButtonHidden(true)
                case .artworkDetail(let id):
                    ArtworkDetailView(artworkId: id)
                case .camera:
                    CameraView()
                        .toolbar(.hidden, for: .navigationBar)
                case .archive(let id):
                    ArchiveView(exhibitionId: id)
                        .toolbar(.hidden, for: .navigationBar)
                case .category:
                    CategoryView()
                case .completeReaction:
                    CompleteReactionView()
                case .inputArtworkInfo(let image):
                    InputArtworkInfoView(image: image)
                case .articleExhibitionList:
                    ArticleExhibitionListView()
                        .navigationBarBackButtonHidden(true)
                case .articleList(let selectedExhibitionId):
                    ArticleListView(selectedExhibitionId: selectedExhibitionId)
                        .navigationBarBackButtonHidden(true)
                case .completeArticleList(let selectedExhibitionId, let selectedArtistId):
                    CompleteArticleListView(selectedExhibitionId: selectedExhibitionId, selectedArtistId: selectedArtistId)
                        .navigationBarBackButtonHidden(true)
                case .artistReaction:
                    ArtistReactionView()
                        .toolbar(.hidden, for: .navigationBar)
                case .artistReactionArchiveView:
                    ArtistReactionArchiveView()
                        .toolbar(.hidden, for: .navigationBar)
                case .exhibitionArchive(exhibitionId: let exhibitionId):
                    ExhibitionArchiveView(exhibitionId: exhibitionId)
                        .toolbar(.hidden, for: .navigationBar)
                }
            }
        }
        .environmentObject(router)
    }

    // 테스트용 더미 이미지 생성
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 400, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let text = "테스트 이미지"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}
