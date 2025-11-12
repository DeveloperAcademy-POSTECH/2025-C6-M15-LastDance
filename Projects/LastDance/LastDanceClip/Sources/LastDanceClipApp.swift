//
//  LastDanceClipApp.swift
//  LastDanceClip
//
//  Created by 배현진 on 11/8/25.
//

import SwiftUI

@main
struct LastDanceClipApp: App {
    @StateObject private var router = ClipNavigationRouter()

    var body: some Scene {
        WindowGroup {
            ClipRootView()
                .environmentObject(router)
                .onOpenURL { url in
                    handle(url: url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    if let url = activity.webpageURL {
                        handle(url: url)
                    }
                }
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }

    /// URL → 라우트로 변환
    private func handle(url: URL) {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let pathComponents = url.pathComponents

        let artworkId: Int = {
            if pathComponents.count >= 3 {
                return Int(pathComponents[2]) ?? 0
            } else {
                return 0
            }
        }()

        let exhibitionId: Int = {
            comps?.queryItems?
                .first(where: { $0.name == "exhibitionId" })?
                .value
                .flatMap(Int.init) ?? 0
        }()
        
        let route: ClipRoute = .artworkDetail(
            artworkId: artworkId,
            exhibitionId: exhibitionId
        )

        router.path = [route]
    }
}
