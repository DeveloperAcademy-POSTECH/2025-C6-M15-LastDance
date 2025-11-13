//
//  ClipNavigationRouter.swift
//  LastDance
//
//  Created by 배현진 on 11/10/25.
//

import SwiftUI

final class ClipNavigationRouter: ObservableObject {
    @Published var path: [ClipRoute] = []

    func push(_ route: ClipRoute) {
        path.append(route)
    }

    func popLast() {
        _ = path.popLast()
    }

    func reset() {
        path.removeAll()
    }
}
