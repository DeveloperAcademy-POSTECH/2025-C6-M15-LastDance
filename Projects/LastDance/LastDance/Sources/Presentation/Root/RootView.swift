//
//  RootView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = NavigationRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            OnboardingView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .identitySelection:
                        IdentitySelectionView()
                    case .audienceArchiving:
                        AudienceArchivingView()
                    case .articleArchiving:
                        ArticleArchivingView()
                    case .exhibitionList:
                        ExhibitionListView()
                    case .exhibitionDetail(let id):
                        ExhibitionDetailView(exhibitionId: id)
                            .navigationBarBackButtonHidden(true)
                    case .artworkDetail(let id):
                        ArtworkDetailView(artworkId: id)
                    case .camera:
                        CameraView()
                            .toolbar(.hidden, for: .navigationBar)
                    case .archive:
                        ArchiveView()
                    case .category:
                        CategoryView()
                    case .completeReaction:
                        CompleteReactionView()
                    case .inputArtworkInfo(let image, let exhibitionId, let artistId):
                        InputArtworkInfoView(image: image, exhibitionId: exhibitionId, artistId: artistId)
                    case .articleExhibitionList:
                        ArticleExhibitionListView()
                    case .articleList(let selectedExhibitionId):
                        ArticleListView(selectedExhibitionId: selectedExhibitionId)
                    case .completeArticleList(let selectedExhibitionId, let selectedArtistId):
                        CompleteArticleListView(selectedExhibitionId: selectedExhibitionId, selectedArtistId: selectedArtistId)
                    }
                }
        }
        .environmentObject(router)
    }
}
