//
//  SwiftDataManager.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

/// 앱 전역에서 SwiftData를 다루는 매니저.
/// View 밖(ViewModel, Service 등)에서 데이터 접근 시 사용합니다.
@MainActor
final class SwiftDataManager {
    static let shared = SwiftDataManager()

    private(set) var container: ModelContainer?
    var context: ModelContext {
        guard let container = container else {
            fatalError("ModelContainer가 아직 설정되지 않았습니다.")
        }
        return container.mainContext
    }

    private init() {}

    /// 앱 초기화 시점에 ModelContainer를 주입
    func configure(with container: ModelContainer) {
        self.container = container
    }

    // MARK: - CRUD

    /// 새 객체 추가
    func insert<T: PersistentModel>(_ object: T) {
        context.insert(object)
    }

    /// 특정 객체 삭제
    func delete<T: PersistentModel>(_ object: T) {
        context.delete(object)
        saveContext()
    }

    /// 모든 데이터 가져오기
    func fetchAll<T: PersistentModel>(_: T.Type) -> [T] {
        do {
            let descriptor = FetchDescriptor<T>()

            return try context.fetch(descriptor)
        } catch {
            Log.error("Fetch 실패: \(error)")
            return []
        }
    }

    /// 술어를 사용하여 데이터 가져오기
    func fetch<T: PersistentModel>(_: T.Type, predicate: Predicate<T>) -> [T] {
        do {
            let descriptor = FetchDescriptor<T>(predicate: predicate)
            return try context.fetch(descriptor)
        } catch {
            Log.error("Fetch with predicate 실패: \(error)")
            return []
        }
    }

    /// 특정 id를 가진 객체 가져오기
    func fetchById<T: PersistentModel & Identifiable>(_: T.Type, id: String) -> T? {
        do {
            let predicate = #Predicate<T> { ($0 as? any HasStringId)?.id == id }
            let descriptor = FetchDescriptor<T>(predicate: predicate)
            return try context.fetch(descriptor).first
        } catch {
            Log.error("FetchById 실패: \(error)")
            return nil
        }
    }

    /// 저장
    func saveContext() {
        do {
            try context.save()
        } catch {
            Log.error("SwiftData 저장 실패: \(error)")
        }
    }

    // 사용자가 선택한 작품-작가 매칭이 데이터와 다를 때 사용
    /// 작품의 artistId 업데이트
    func updateArtworkArtist(artworkId: Int, artistId: Int) {
        let artworks = fetchAll(Artwork.self)
        if let artwork = artworks.first(where: { $0.id == artworkId }) {
            artwork.artistId = artistId
            saveContext()
            Log.debug("작품 artistId 업데이트 완료 - artworkId: \(artworkId), artistId: \(artistId)")
        } else {
            Log.error("작품을 찾을 수 없음 - artworkId: \(artworkId)")
        }
    }
}

// MARK: - 중복 방지를 위해서 insert + update를 위한 기능

extension SwiftDataManager {
    /// Venue 전체 목록 저장 - 중복 방지
    func upsertVenue(_ newValue: Venue) {
        let all = fetchAll(Venue.self)
        if let existing = all.first(where: { $0.id == newValue.id }) {
            existing.name = newValue.name
            existing.address = newValue.address
            existing.geoLat = newValue.geoLat
            existing.geoLon = newValue.geoLon
        } else {
            insert(newValue)
        }
    }

    /// Visitor 전체 목록 저장 - 중복 방지
    func upsertVisitor(_ newValue: Visitor) {
        let all = fetchAll(Visitor.self)
        if let existing = all.first(where: { $0.id == newValue.id }) {
            existing.uuid = newValue.uuid
            existing.name = newValue.name
        } else {
            insert(newValue)
        }
    }

    /// Artist 전체 목록 저장 - 중복 방지
    func upsertArtist(_ newValue: Artist) {
        let all = fetchAll(Artist.self)
        if let existing = all.first(where: { $0.id == newValue.id }) {
            existing.uuid = newValue.uuid
            existing.name = newValue.name
        } else {
            insert(newValue)
        }
    }

    /// Exhitibion 전체 목록 저장 - 중복 방지
    func upsertExhibition(_ newValue: Exhibition) {
        let all = fetchAll(Exhibition.self)
        if let existing = all.first(where: { $0.id == newValue.id }) {
            existing.title = newValue.title
            existing.descriptionText = newValue.descriptionText
            existing.startDate = newValue.startDate
            existing.endDate = newValue.endDate
            existing.venueId = newValue.venueId
            existing.coverImageName = newValue.coverImageName
            existing.createdAt = newValue.createdAt
            existing.updatedAt = newValue.updatedAt
        } else {
            insert(newValue)
        }
    }

    /// Artwork 전체 목록 저장 - 중복 방지
    func upsertArtwork(_ newValue: Artwork) {
        let all = fetchAll(Artwork.self)
        if let existing = all.first(where: { $0.id == newValue.id }) {
            existing.exhibitionId = newValue.exhibitionId
            existing.title = newValue.title
            existing.descriptionText = newValue.descriptionText
            existing.artistId = newValue.artistId
            existing.thumbnailURL = newValue.thumbnailURL
            existing.exhibition = newValue.exhibition

        } else {
            insert(newValue)
        }
        //        printAllArtworks()
    }

    /// 전체 Venue 확인용 출력문
    //    func printAllVenues() {
    //        let venues = SwiftDataManager.shared.fetchAll(Venue.self)
    //        Log.debug("------ Venue Local Data ------")
    //        venues.forEach { venue in
    //            Log.debug("id=\(venue.id), uuid=\(venue.name), name=\(venue.address ?? "nil"), geoLat=\(venue.geoLat ?? 0), geoLon=\(venue.geoLon ?? 0)")
    //        }
    //        Log.debug("-------------------------------")
    //    }

    /// 전체 Visitor 확인용 출력문
    //    func printAllVisitors() {
    //        let visitors = SwiftDataManager.shared.fetchAll(Visitor.self)
    //        Log.debug("------ Visitor Local Data ------")
    //        visitors.forEach { visitor in
    //            Log.debug("id=\(visitor.id), uuid=\(visitor.uuid), name=\(visitor.name ?? "nil")")
    //        }
    //        Log.debug("-------------------------------")
    //    }

    /// 전체 Artist 확인용 출력문
    //    func printAllArtworks() {
    //        let artworks = SwiftDataManager.shared.fetchAll(Artwork.self)
    //        Log.debug("------ Artist Local Data ------")
    //        artworks.forEach { artwork in
    //            Log.debug("id=\(artwork.id), exhibitionId=\(artwork.exhibitionId)")
    //        }
    //        Log.debug("-------------------------------")
    //    }
}

/// 문자열 id를 가진 모델을 위한 프로토콜
protocol HasStringId {
    var id: String { get }
}
