//
//  AppClipURLCoordinator.swift
//  LastDance
//
//  Created by 배현진 on 11/13/25.
//

import Foundation

/// AppClip 진입시점에 URL을 파싱하고 라우팅을 실행
class AppClipURLCoordinator {
    private let router: ClipNavigationRouter

    init(router: ClipNavigationRouter) {
        self.router = router
    }
    
    func handle(url: URL) {
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
