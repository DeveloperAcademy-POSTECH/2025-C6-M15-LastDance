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
                    case .reaction:
                        ReactionInputView()
                    case .archive:
                        ArchiveView()
                    case .category:
                        CategoryView()
                    case .completeReaction:
                        CompleteReactionView()
                    }
                }
        }
        .environmentObject(router)
    }
}
