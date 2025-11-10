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
            Group{
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
                case .exhibitionDetail(let id):
                    ExhibitionDetailView(exhibitionId: id)
                        .navigationBarBackButtonHidden(true)
                case .artworkDetail(let id, let capturedImage, let exhibitionId):
                    ArtworkDetailView(artworkId: id, capturedImage: capturedImage, exhibitionId: exhibitionId)
                        .navigationBarBackButtonHidden(true)
                case .camera(let exhibitionId):
                    CameraView(exhibitionId: exhibitionId)
                        .toolbar(.hidden, for: .navigationBar)
                case .captureConfirm(let imageData, let exhibitionId):
                    CaptureConfirmView(imageData: imageData, exhibitionId: exhibitionId)
                        .navigationBarBackButtonHidden(true)
                case .archive(let id):
                    ArchiveView(exhibitionId: id)
                        .toolbar(.hidden, for: .navigationBar)
                case .category:
                    CategorySelectView()
                        .navigationBarBackButtonHidden(true)
                case .reactionTags:
                    TagSelectView()
                        .navigationBarBackButtonHidden(true)
                case .completeReaction(let exhibitionId):
                    CompleteReactionView(exhibitionId: exhibitionId)
                case .inputArtworkInfo(let image, let exhibitionId, let artistId):
                    InputArtworkInfoView(
                        image: image,
                        exhibitionId: exhibitionId,
                        artistId: artistId
                    )
                        .navigationBarBackButtonHidden(true)
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
                case .response(let artworkId):
                    ResponseView(artworkId: artworkId)
                        .navigationBarBackButtonHidden(true)
                case .artReaction(let artwork, let artist):
                    ArtReactionView(artwork: artwork, artist: artist)
                        .navigationBarBackButtonHidden(true)
                case .alarmList(let userType):
                    AlarmListView(userType: userType)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .environmentObject(router)
        .environmentObject(reactionInputViewModel)
    }
}
