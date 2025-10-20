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
                if let userType = userType {
                    switch userType {
                    case .artist:
                        ArticleArchivingView()
                    case .viewer:
                        AudienceArchivingView()
                    }
                } else {
                    IdentitySelectionView()
                }
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
                case .artworkDetail(let id, let capturedImage):
                    ArtworkDetailView(artworkId: id, capturedImage: capturedImage)
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
                case .inputArtworkInfo(let image, let exhibitionId, let artistId):
                    InputArtworkInfoView(image: image, exhibitionId: exhibitionId, artistId: artistId)
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
                case .artistReactionArchiveView(let exhibitionId):
                    ArtistReactionArchiveView(exhibitionId: exhibitionId)
                        .toolbar(.hidden, for: .navigationBar)
                case .exhibitionArchive(exhibitionId: let exhibitionId):
                    ExhibitionArchiveView(exhibitionId: exhibitionId)
                        .toolbar(.hidden, for: .navigationBar)
                case .archiveHome:
                    ArchiveHomeView()
                }
            }
        }
        .environmentObject(router)
    }
}
