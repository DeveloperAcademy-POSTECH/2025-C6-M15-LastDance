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
    
    // ModelContainer 설정을 분리한 PersistenceController 사용
    let persistenceController = PersistenceController()
    
    // 데이터 동기화 로직을 분리한 Coordinator 사용
    let dataCoordinator: AppDataCoordinator

    init() {
        let visitorService = VisitorAPIService()
        let reactionService = ReactionAPIService()
        let exhibitionService = ExhibitionAPIService()

        // 모든 의존성을 주입하여 코디네이터 생성
        self.dataCoordinator = AppDataCoordinator(
            visitorService: visitorService,
            reactionService: reactionService,
            exhibitionService: exhibitionService
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    await dataCoordinator.startHandoffProcess()
                }
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
            
                // TODO: - 개발 시점에 목데이터 사용 여부에 따라 주석 처리
                // .onAppear {
                //     #if DEBUG
                //     Task { @MainActor in
                //         MockDataLoader.seedIfNeeded(container: persistenceController.sharedModelContainer)
                //     }
                //     #endif
                // }
        }
        .modelContainer(persistenceController.sharedModelContainer)
    }
}
