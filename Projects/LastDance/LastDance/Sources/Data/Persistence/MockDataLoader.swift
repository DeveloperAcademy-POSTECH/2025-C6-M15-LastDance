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
    /// 필요 시점에 한번만 시드 추가
    static func seedIfNeeded(container: ModelContainer) {
        #if DEBUG
        guard UserDefaults.standard.bool(forKey: .seed) == false else { return }
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
        let artistKim = Artist(id: "artist_kim", name: "Kim", exhibitions: ["exhibition_light"], receivedReactions: [])
        let artistPark = Artist(id: "artist_park", name: "Park", exhibitions: ["exhibition_light"], receivedReactions: [])
        let artistLee = Artist(id: "artist_lee", name: "Lee", exhibitions: ["exhibition_light"], receivedReactions: [])
        let artistKong = Artist(id: "artist_kong", name: "Kong", exhibitions: ["exhibition_light"], receivedReactions: [])
        let artistSoo = Artist(id: "artist_soo", name: "Soo", exhibitions: ["exhibition_light"], receivedReactions: [])

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

        // 샘플 Artworks
        let artwork1 = Artwork(
            id: "artwork_light_01",
            exhibitionId: exhibition.id,
            title: "Light #1",
            artistId: artistKim.id,
            thumbnailURL: "mock_artworkImage_01"
        )
        let artwork2 = Artwork(
            id: "artwork_light_02",
            exhibitionId: exhibition.id,
            title: "Light #2",
            artistId: artistKim.id,
            thumbnailURL: "mock_artworkImage_02"
        )
        let artwork3 = Artwork(
            id: "artwork_light_02",
            exhibitionId: exhibition.id,
            title: "Light #2",
            artistId: artistKim.id,
            thumbnailURL: "mock_artworkImage_02"
        )
        let artwork4 = Artwork(
            id: "artwork_light_02",
            exhibitionId: exhibition.id,
            title: "Light #2",
            artistId: artistKim.id,
            thumbnailURL: "mock_artworkImage_02"
        )
        exhibition.artworks = [artwork1, artwork2, artwork3, artwork4]

        // 로컬 생성 User (앱에서 만들어지는 데이터)
        let user = User(role: "Visitor")

        // 임시 캡처/반응
        let capture1 = CapturedArtwork(
            id: UUID().uuidString,
            artworkId: artwork1.id,
            localImagePath: "file:///tmp/mock1.jpg",
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
        artistKim.receivedReactions.append(reaction1)

        // 컨텍스트에 insert
        context.insert(venue)
        context.insert(artistKim)
        context.insert(exhibition)
        context.insert(artwork1); context.insert(artwork2)
        context.insert(user)
        context.insert(capture1)
        context.insert(reaction1)

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: .seed)
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
        UserDefaults.standard.set(false, forKey: .seed)
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
