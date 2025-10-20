//
//  LastDanceApp.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftData
import SwiftUI

@main
struct LastDanceApp: App {
    let sharedModelContainer: ModelContainer
    @StateObject private var keyboardManager = KeyboardManager()
    
    init() {
        do {
            let schema = Schema([
                Exhibition.self,
                Artwork.self,
                Artist.self,
                Visitor.self,
                Venue.self,
                CapturedArtwork.self,
                Reaction.self,
                IdentificatedArtwork.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false 
            )

            self.sharedModelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        // SwiftUI가 아닌 외부에서 사용 가능하도록 SwiftDataManager에 container 주입
        SwiftDataManager.shared.configure(with: sharedModelContainer)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.keyboardManager, keyboardManager)
            // TODO: - 개발 시점에 목데이터 사용 원할시 주석 해제
//                .onAppear {
//                    #if DEBUG
//                    Task { @MainActor in
//                        MockDataLoader.seedIfNeeded(container: sharedModelContainer)
//                    }
//                    #endif
//                }
        }
        .modelContainer(sharedModelContainer)
    }
}
