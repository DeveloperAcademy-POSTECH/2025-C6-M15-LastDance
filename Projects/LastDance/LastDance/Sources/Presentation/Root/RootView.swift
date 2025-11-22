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
    @StateObject private var identitySelectionViewModel = IdentitySelectionViewModel()
    @State private var userType: UserType?
    @State private var showLaunchScreen: Bool = true

    init() {
        var initialUserType: UserType?
        if let userTypeValue = UserDefaults.standard.string(forKey: UserDefaultsKey.userType.key) {
            initialUserType = UserType(rawValue: userTypeValue)
        }
        _userType = State(initialValue: initialUserType)
    }

    var body: some View {
        ZStack {
            // 메인 뷰 플로우
            mainContent
                .opacity(showLaunchScreen ? 0 : 1)

            // 런치스크린
            if showLaunchScreen {
                LaunchScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showLaunchScreen = false
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HandleDeepLink")))
        { notification in
            if let userInfo = notification.userInfo,
                let url = userInfo["url"] as? URL
            {
                Log.debug("RootView에서 딥링크 수신: \(url.absoluteString)")
                router.handleDeepLink(url)
            }
        }
        .environmentObject(router)
        .environmentObject(reactionInputViewModel)
        .environmentObject(identitySelectionViewModel)
    }

    private var mainContent: some View {
        NavigationStack(path: $router.path) {
            Group {
                if let userType = userType {
                    switch userType {
                    case .artist:
                        // 작가 인증 여부 확인
                        if identitySelectionViewModel.isArtistAuthenticated() {
                            ArticleArchivingView()
                        } else {
                            ArtistCodeInputView()
                        }
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
                case .artistCodeInput:
                    ArtistCodeInputView()
                        .navigationBarBackButtonHidden(true)
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
                    ArtworkDetailView(
                        artworkId: id, capturedImage: capturedImage, exhibitionId: exhibitionId
                    )
                    .navigationBarBackButtonHidden(true)
                case .camera(let exhibitionId):
                    CameraView(exhibitionId: exhibitionId)
                        .toolbar(.hidden, for: .navigationBar)
                case .captureConfirm(let imageData, let exhibitionId):
                    CaptureConfirmView(imageData: imageData, exhibitionId: exhibitionId)
                        .navigationBarBackButtonHidden(true)
                case .archive(let id):
                    ArchiveView(exhibitionId: id)
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
                    CompleteArticleListView(
                        selectedExhibitionId: selectedExhibitionId,
                        selectedArtistId: selectedArtistId
                    )
                    .navigationBarBackButtonHidden(true)
                case .artistReaction:
                    ArtistReactionView()
                        .toolbar(.hidden, for: .navigationBar)
                case .artistReactionArchiveView(let exhibitionId):
                    ArtistReactionArchiveView(exhibitionId: exhibitionId)
                        .navigationBarBackButtonHidden(true)
                case .exhibitionArchive(let exhibitionId):
                    ExhibitionArchiveView(exhibitionId: exhibitionId)
                        .background(LDColor.color6)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                case .response(let artworkId):
                    ArtworkReactionView(artworkId: artworkId)
                        .navigationBarBackButtonHidden(true)
                case .artReaction(let artwork, let artist):
                    ArtReactionView(artwork: artwork, artist: artist)
                        .navigationBarBackButtonHidden(true)
                case .alarmList(let userType):
                    AlarmListView(userType: userType)
                        .navigationBarBackButtonHidden(true)
                case .createInvitation:
                    CreateInvitationView()
                        .navigationBarBackButtonHidden(true)
                case .selectExhibitionForInvitation:
                    SelectExhibitionForInvitationView()
                        .navigationBarBackButtonHidden(true)
                case .invitationDetail(let exhibition):
                    InvitationDetailView(exhibition: exhibition)
                        .navigationBarBackButtonHidden(true)
                case .invitationShare(let invitation):
                    CreatedInvitationView(invitation: invitation)
                        .navigationBarBackButtonHidden(true)
                case .receivedInvitation(let invitationCode):
                    ReceivedInvitationView(invitationCode: invitationCode)
                        .navigationBarBackButtonHidden(false)
                }
            }
        }
        .environmentObject(router)
        .environmentObject(reactionInputViewModel)
        .environmentObject(identitySelectionViewModel)
        .onOpenURL { url in
            Log.debug("딥링크 수신: \(url.absoluteString)")
            router.handleDeepLink(url)
        }
    }
}
