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
    
    private let urlCoordinator: AppClipURLCoordinator
    
    init() {
        let routerInstance = ClipNavigationRouter()
        self._router = StateObject(wrappedValue: routerInstance)
        self.urlCoordinator = AppClipURLCoordinator(router: routerInstance)
    }
    
    var body: some Scene {
        WindowGroup {
            ClipRootView()
                .environmentObject(router)
                .onOpenURL { url in
                    urlCoordinator.handle(url: url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    if let url = activity.webpageURL {
                        urlCoordinator.handle(url: url)
                    }
                }
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}
