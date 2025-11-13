//
//  ClipRootView.swift
//  LastDanceClip
//
//  Created by 배현진 on 11/10/25.
//

import SwiftData
import SwiftUI

struct ClipRootView: View {
    @EnvironmentObject private var router: ClipNavigationRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            ProgressView()
            .navigationDestination(for: ClipRoute.self) { route in
                switch route {
                case .artworkDetail(let artworkId, let exhibitionId):

                    ClipArtReactionView(
                        artworkId: artworkId,
                        exhibitionId: exhibitionId
                    )
                    .toolbar(.hidden, for: .navigationBar)

                case .complete:
                    ClipCompleteView()
                }
            }
        }
    }
}
