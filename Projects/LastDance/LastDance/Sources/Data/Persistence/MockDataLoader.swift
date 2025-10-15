//
//  MockDataSeeder.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@MainActor
enum MockDataLoader {
    private static let seedKey = "seed.v1"

    /// 필요 시점에 한번만 시드 추가
    static func seedIfNeeded(container: ModelContainer) {
        #if DEBUG
        guard UserDefaults.standard.bool(forKey: seedKey) == false else { return }
        let context = container.mainContext

        // 샘플 Venue
        let venue = Venue(
            id: "venue_seoulmuseum",
            name: "Seoul Museum",
            address: "Seoul",
            geoLat: 37.5665,
            geoLon: 126.9780
        )

        // 샘플 Artist
        let artist = Artist(id: "artist_kim", name: "Kim", exhibitions: ["exhibition_light"], receivedReactions: [])

        // 샘플 Exhibition
        let exhibition = Exhibition(
            id: "exhibition_light",
            title: "빛의 향연",
            descriptionText: "현대 미술에서 빛의 감각을 탐구하는 전시",
            startDate: Date().addingTimeInterval(-86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 14),
            venueId: venue.id,
            coverImageName: "mock_exhibitionCoverImage"
        )
        
        // 샘플 Exhibition 3개
        let exhibition1 = Exhibition(
            id: "exhibition_02",
            title: "조샘초이 : 기억의 지층, 경계를 넘는 시선",
            descriptionText: "조샘초이 작가의 개인전",
            startDate: Date().addingTimeInterval(-86400 * 8),
            endDate: Date().addingTimeInterval(86400 * 15),
            venueId: venue.id,
            coverImageName: "mock_exhibitionCoverImage"
        )
        
        let exhibition2 = Exhibition(
            id: "exhibition_03",
            title: "기증작가 상설전: 박대성 소산수목",
            descriptionText: "박대성 작가의 기증 작품 전시",
            startDate: Date().addingTimeInterval(-86400 * 6),
            endDate: Date().addingTimeInterval(86400 * 12),
            venueId: venue.id,
            coverImageName: "mock_artworkImage_02"
        )
        
        let exhibition3 = Exhibition(
            id: "exhibition_04",
            title: "清年! 青年! 請年! - 맑고 푸른 그대에게 청한다",
            descriptionText: "젊은 작가들의 작품 전시",
            startDate: Date().addingTimeInterval(-86400 * 10),
            endDate: Date().addingTimeInterval(86400 * 20),
            venueId: venue.id,
            coverImageName: "mock_artworkImage_01"
        )
        // 샘플 Artworks
        let artwork1 = Artwork(
            id: "artwork_light_01",
            exhibitionId: exhibition.id,
            title: "Light #1",
            artistId: artist.id,
            thumbnailURL: "mock_artworkImage_01"
        )
        let artwork2 = Artwork(
            id: "artwork_light_02",
            exhibitionId: exhibition.id,
            title: "Light #2",
            artistId: artist.id,
            thumbnailURL: "mock_artworkImage_02"
        )
        exhibition.artworks = [artwork1, artwork2]
        // 로컬 생성 User (앱에서 만들어지는 데이터)
        let user = User(role: "Visitor")

        // 임시 캡처/반응 (6개의 캡처 생성)
        let capture1 = CapturedArtwork(
            id: UUID().uuidString,
            artworkId: artwork1.id,
            localImagePath: "file:///tmp/mock1.jpg",
            createdAt: .now.addingTimeInterval(-300)
        )
        let capture2 = CapturedArtwork(
            id: UUID().uuidString,
            artworkId: artwork1.id,
            localImagePath: "mock_artworkImage_01",
            createdAt: .now.addingTimeInterval(-200)
        )
        let capture3 = CapturedArtwork(
            id: UUID().uuidString,
            artworkId: artwork2.id,
            localImagePath: "mock_artworkImage_02",
            createdAt: .now.addingTimeInterval(-100)
        )
        let capture4 = CapturedArtwork(
            id: UUID().uuidString,
            artworkId: artwork2.id,
            localImagePath: "mock_artworkImage_01",
            createdAt: .now
        )
        let capture5 = CapturedArtwork(
            id: UUID().uuidString,
            artworkId: artwork2.id,
            localImagePath: "mock_artworkImage_01",
            createdAt: .now
        )
        let capture6 = CapturedArtwork(
            id: UUID().uuidString,
            artworkId: artwork2.id,
            localImagePath: "mock_artworkImage_02",
            createdAt: .now
        )
        
        let reaction1  = Reaction(
            id: UUID().uuidString,
            artworkId: artwork1.id,
            userId: user.id.uuidString,
            category: ["좋아요"],
            comment: "빛이 멋져요",
            createdAt: .now
        )

        // 관계 연결
        user.sentReactions.append(reaction1)
        artist.receivedReactions.append(reaction1)

        // 컨텍스트에 insert
        context.insert(venue)
        context.insert(artist)
        context.insert(exhibition)
        context.insert(exhibition1)
        context.insert(exhibition2)
        context.insert(exhibition3)
        context.insert(artwork1); context.insert(artwork2)
        context.insert(user)
        context.insert(capture1)
        context.insert(capture2)
        context.insert(capture3)
        context.insert(capture4)
        context.insert(capture5)
        context.insert(capture6)
        context.insert(reaction1)

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: seedKey)
            Log.debug("DEV seed completed.")
        } catch {
            Log.debug("DEV seed failed: \(error)")
        }
        #endif
    }

    /// 초기화가 필요할 때 전체 삭제 (개발용)
    static func wipeAll(container: ModelContainer) {
        #if DEBUG
        let ctx = container.mainContext
        _ = try? ctx.delete(model: Exhibition.self)
        _ = try? ctx.delete(model: Artwork.self)
        _ = try? ctx.delete(model: Artist.self)
        _ = try? ctx.delete(model: Venue.self)
        _ = try? ctx.delete(model: User.self)
        _ = try? ctx.delete(model: CapturedArtwork.self)
        _ = try? ctx.delete(model: Reaction.self)
        _ = try? ctx.delete(model: IdentificatedArtwork.self)
        try? ctx.save()
        UserDefaults.standard.set(false, forKey: seedKey)
        Log.debug("🧹 wiped all & seed flag reset")
        #endif
    }
}

private extension ModelContext {
    /// 모든 레코드 삭제 유틸 (개발용)
    func delete<T: PersistentModel>(model: T.Type) throws -> Int {
        let items = try fetch(FetchDescriptor<T>())
        items.forEach { delete($0) }
        try save()
        return items.count
    }
}
