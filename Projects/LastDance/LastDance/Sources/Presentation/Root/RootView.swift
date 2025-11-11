//
//  RootView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = NavigationRouter()
    @StateObject private var reactionInputViewModel = ReactionInputViewModel()
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
                        .navigationBarBackButtonHidden(true)
                case let .exhibitionDetail(id):
                    ExhibitionDetailView(exhibitionId: id)
                        .navigationBarBackButtonHidden(true)
                case let .artworkDetail(id, capturedImage, exhibitionId):
                    ArtworkDetailView(artworkId: id, capturedImage: capturedImage, exhibitionId: exhibitionId)
                        .navigationBarBackButtonHidden(true)
                case let .camera(exhibitionId):
                    CameraView(exhibitionId: exhibitionId)
                        .toolbar(.hidden, for: .navigationBar)
                case let .captureConfirm(imageData, exhibitionId):
                    CaptureConfirmView(imageData: imageData, exhibitionId: exhibitionId)
                        .navigationBarBackButtonHidden(true)
                case let .archive(id):
                    ArchiveView(exhibitionId: id)
                        .toolbar(.hidden, for: .navigationBar)
                case .category:
                    CategorySelectView()
                        .navigationBarBackButtonHidden(true)
                case .reactionTags:
                    TagSelectView()
                        .navigationBarBackButtonHidden(true)
                case let .completeReaction(exhibitionId):
                    CompleteReactionView(exhibitionId: exhibitionId)
                case let .inputArtworkInfo(image, exhibitionId, artistId):
                    InputArtworkInfoView(
                        image: image,
                        exhibitionId: exhibitionId,
                        artistId: artistId
                    )
                    .navigationBarBackButtonHidden(true)
                case .articleExhibitionList:
                    ArticleExhibitionListView()
                        .navigationBarBackButtonHidden(true)
                case let .articleList(selectedExhibitionId):
                    ArticleListView(selectedExhibitionId: selectedExhibitionId)
                        .navigationBarBackButtonHidden(true)
                case let .completeArticleList(selectedExhibitionId, selectedArtistId):
                    CompleteArticleListView(
                        selectedExhibitionId: selectedExhibitionId, selectedArtistId: selectedArtistId
                    )
                    .navigationBarBackButtonHidden(true)
                case .artistReaction:
                    ArtistReactionView()
                        .toolbar(.hidden, for: .navigationBar)
                case let .artistReactionArchiveView(exhibitionId):
                    ArtistReactionArchiveView(exhibitionId: exhibitionId)
                        .toolbar(.hidden, for: .navigationBar)
                case let .exhibitionArchive(exhibitionId):
                    ExhibitionArchiveView(exhibitionId: exhibitionId)
                        .toolbar(.hidden, for: .navigationBar)
                case let .response(artworkId):
                    ResponseView(artworkId: artworkId)
                        .navigationBarBackButtonHidden(true)
                case let .artReaction(artwork, artist):
                    ArtReactionView(artwork: artwork, artist: artist)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .environmentObject(router)
        .environmentObject(reactionInputViewModel)
    }
}
