//
//  ContentView.swift
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
            // 기본 화면 – 사실 바로 artworkDetail로 들어오니까 거의 안 보임
            Text("작품을 불러오는 중입니다…")
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
