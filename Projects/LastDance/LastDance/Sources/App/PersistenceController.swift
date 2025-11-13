//
//  PersistenceController.swift
//  LastDance
//
//  Created by 배현진 on 11/13/25.
//

import Foundation
import SwiftData

/// 앱 전체에서 공유할 ModelContainer 구성
@MainActor
struct PersistenceController {
    let sharedModelContainer: ModelContainer

    init() {
        do {
            // 프로젝트에 정의된 모든 모델을 명시
            let schema = Schema([
                Exhibition.self,
                Artwork.self,
                Artist.self,
                Visitor.self,
                Venue.self,
                CapturedArtwork.self,
                Reaction.self,
                IdentificatedArtwork.self,
                VisitHistory.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            self.sharedModelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            SwiftDataManager.shared.configure(with: sharedModelContainer)
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
