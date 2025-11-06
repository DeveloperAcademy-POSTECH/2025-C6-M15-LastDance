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
}
