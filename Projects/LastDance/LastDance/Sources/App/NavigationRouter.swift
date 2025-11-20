//
//  NavigationRouter.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

/// SwiftUI NavigationStack 기반 라우터
final class NavigationRouter: ObservableObject {
    @Published var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func popLast() {
        _ = path.popLast()
    }

    func removeAll() {
        path.removeAll()
    }

    /// 특정 화면까지 전부 pop
    func popTo(_ target: Route) {
        Log.debug("popTo: Target: \(target)")
        while let last = path.last {
            Log.debug("popTo: Current last in path: \(last)")
            if last == target {
                Log.debug("popTo: Found target: \(target)")
                break
            }
            _ = path.popLast()
        }
        Log.debug("popTo: Path after operation: \(path)")
    }

    func popToLast(where predicate: (Route) -> Bool) {
        guard let lastIndex = path.lastIndex(where: predicate) else { return }
        path.removeSubrange((lastIndex + 1)...)
    }

    /// 딥링크 처리
    func handleDeepLink(_ url: URL) {
        let deepLinkType = DeepLinkHandler.parse(url)

        switch deepLinkType {
        case .invitation(let uuid):
            Log.debug("초대장 딥링크 처리 - UUID: \(uuid)")
            // 초대장 화면으로 이동
            push(.receivedInvitation(invitationCode: uuid))

        case .unknown:
            Log.error("알 수 없는 딥링크")
        }
    }
}
