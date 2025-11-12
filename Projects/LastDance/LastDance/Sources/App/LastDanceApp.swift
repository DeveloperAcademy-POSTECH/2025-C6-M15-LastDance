//
//  LastDanceApp.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftData
import SwiftUI
import Moya

@main
struct LastDanceApp: App {
    @State private var clipPayload: ClipPayload?

    let sharedModelContainer: ModelContainer
    
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
                .task {
                    // App Clip이 남긴 데이터 있는지 확인
                    let manager = AppClipHandOffManager()
                    if let payload = manager.consumeClipPayload() {
                        // 서버에서 최신 반응/방문 정보 다시 받아오기
                        await fetchLatestForClipPayload(payload)
                    }
                }
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
            // TODO: - 개발 시점에 목데이터 사용 여부에 따라 주석 처리
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
    
    @MainActor
    private func fetchLatestForClipPayload(_ payload: ClipPayload) async {
        // 공용 서비스 준비
        let visitorService = VisitorAPIService()
        let visitHistoryProvider = MoyaProvider<VisitHistoriesAPI>()
        let reactionService = ReactionAPIService()

        // AppGroup에 있던 걸 메인앱 UserDefaults.standard 로도 옮겨놓기
        let standard = UserDefaults.standard
        standard.set(payload.visitorUUID, forKey: UserDefaultsKey.visitorUUID.key)
        standard.set(payload.visitorId, forKey: UserDefaultsKey.visitorId.key)
        standard.set(payload.visitId, forKey: UserDefaultsKey.visitId.key)

        // Visitor를 서버에서 다시 가져와서 SwiftData에 넣기
        do {
            let visitorDto = try await withCheckedThrowingContinuation { continuation in
                visitorService.getVisitor(id: payload.visitorId) { result in
                    switch result {
                    case .success(let dto):
                        continuation.resume(returning: dto)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }

            // DTO -> 모델로 변환해서 SwiftData에 저장
            let visitorModel = VisitorMapper.toModel(from: visitorDto)
            SwiftDataManager.shared.upsertVisitor(visitorModel)
            SwiftDataManager.shared.saveContext()
        } catch {
            Log.error("Visitor sync failed from AppClip payload: \(error)")
        }

        // visit-histories도 가져와서 SwiftData에 넣기
        do {
            let histories: [VisitorHistoriesResponseDto] = try await withCheckedThrowingContinuation { continuation in
                visitHistoryProvider.request(
                    .getVisitHistories(
                        visitorId: payload.visitorId,
                        exhibitionId: payload.exhibitionId
                    )
                ) { result in
                    switch result {
                    case .success(let response):
                        do {
                            let decoded = try JSONDecoder().decode(
                                [VisitorHistoriesResponseDto].self,
                                from: response.data
                            )
                            continuation.resume(returning: decoded)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }

            // histories 를 네가 쓰는 로컬 모델로 변환해서 저장
            for dto in histories {
                guard let visitedAt = dto.visitedAtDate else {
                    Log.warning("visited_at 변환 실패: \(dto.visited_at)")
                    continue
                }
                
                let visit = VisitHistory(
                    id: dto.id,
                    visitorId: dto.visitor_id,
                    exhibitionId: dto.exhibition_id,
                    visitedAt: visitedAt
                )
                
                SwiftDataManager.shared.insert(visit)
            }
            
            SwiftDataManager.shared.saveContext()
        } catch {
            Log.error("Visit-histories sync failed: \(error)")
        }

        // AppClip에서 남긴 반응도 서버에서 다시 가져와서 로컬에 저장
        do {
            let reactionDtos = try await reactionService.getReactionsAsync(
                artworkId: payload.artworkId,
                visitorId: payload.visitorId,
                visitId: payload.visitId
            )

            for dto in reactionDtos {
                let reactionModel = ReactionMapper.mapDtoToModel(dto)
                SwiftDataManager.shared.insert(reactionModel)
            }
            SwiftDataManager.shared.saveContext()
        } catch {
            Log.error("Reaction sync failed: \(error)")
        }
        
        await ensureExhibitionExistsAndSelect(exhibitionId: payload.exhibitionId)
    }
    
    @MainActor
    private func ensureExhibitionExistsAndSelect(exhibitionId: Int) async {
        guard let container = SwiftDataManager.shared.container else { return }
        let context = container.mainContext

        // 로컬에 있는지 확인
        let descriptor = FetchDescriptor<Exhibition>(
            predicate: #Predicate<Exhibition> { $0.id == exhibitionId }
        )

        if let existing = try? context.fetch(descriptor).first {
            existing.isUserSelected = true
            try? context.save()
            return
        }

        // 없으면 서버에서 받아와서 넣고 플래그 세운다
        let exhibitionService = ExhibitionAPIService()

        do {
            let dto = try await exhibitionService.getExhibitionDetailAsync(id: exhibitionId)
            let model = ExhibitionMapper.toModel(from: dto)
            model.isUserSelected = true
            context.insert(model)
            try? context.save()
        } catch {
            Log.warning("failed to fetch exhibition \(exhibitionId) from server: \(error)")
        }
    }

}
