//
//  AppDataCoordinator.swift
//  LastDance
//
//  Created by 배현진 on 11/13/25.
//

import Foundation
import Moya
import SwiftData

/// App 진입시점에 필요한 데이터와 네트워크 순서대로 호출
@MainActor
class AppDataCoordinator {

    // 필요한 서비스 객체 준비
    private let appClipHandOffManager = AppClipHandOffManager()
    private let visitHistoryProvider = MoyaProvider<VisitHistoriesAPI>()
    private let visitorService: VisitorAPIServiceProtocol
    private let reactionService: ReactionAPIServiceProtocol
    private let exhibitionService: ExhibitionAPIServiceProtocol

    init(
        visitorService: VisitorAPIServiceProtocol,
        reactionService: ReactionAPIServiceProtocol,
        exhibitionService: ExhibitionAPIServiceProtocol
    ) {
        self.visitorService = visitorService
        self.reactionService = reactionService
        self.exhibitionService = exhibitionService
    }

    // 최상위 진입점
    func startHandoffProcess() async {
        // App Clip이 남긴 데이터 있는지 확인
        if let payload = appClipHandOffManager.consumeClipPayload() {
            Log.info("AppClip Handoff Payload received. Starting sync...")
            await syncData(with: payload)
        }
    }

    // 전체 동기화 프로세스
    private func syncData(with payload: ClipPayload) async {
        // AppGroup에 있던 걸 메인앱 UserDefaults.standard 로도 옮겨놓기
        updateUserDefaults(with: payload)

        // 데이터 동기화
        await syncVisitor(payload: payload)
        await syncVisitHistories(payload: payload)
        await syncReactions(payload: payload)
        await ensureExhibitionExistsAndSelect(exhibitionId: payload.exhibitionId)
    }

    private func updateUserDefaults(with payload: ClipPayload) {
        let standard = UserDefaults.standard
        standard.set(payload.visitorUUID, forKey: UserDefaultsKey.visitorUUID.key)
        standard.set(payload.visitorId, forKey: UserDefaultsKey.visitorId.key)
        standard.set(payload.visitId, forKey: UserDefaultsKey.visitId.key)
    }

    private func syncVisitor(payload: ClipPayload) async {
        // Visitor를 서버에서 가져와서 SwiftData에 넣기
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
    }

    private func syncVisitHistories(payload: ClipPayload) async {
        // visit-histories 가져와서 SwiftData에 넣기
        do {
            let histories: [VisitorHistoriesResponseDto] = try await withCheckedThrowingContinuation
            { continuation in
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
                guard let visit = VisitHistoryMapper.toModel(from: dto) else {
                    continue
                }

                SwiftDataManager.shared.insert(visit)
            }

            SwiftDataManager.shared.saveContext()
        } catch {
            Log.error("Visit-histories sync failed: \(error)")
        }
    }

    private func syncReactions(payload: ClipPayload) async {
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
    }

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

        // 서버에서 받아와서 넣고 플래그 세우기
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
