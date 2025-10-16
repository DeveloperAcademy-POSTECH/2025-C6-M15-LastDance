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

        let venue = createVenue()
        let artists = createArtists()
        let exhibition = createExhibition(venueId: venue.id)
        let artworks = createArtworks(exhibitionId: exhibition.id, artists: artists)
        let user = User(role: "Visitor")
        let (capture, reaction) = createCaptureAndReaction(artworkId: artworks[0].id, userId: user.id.uuidString)

        setupRelationships(user: user, reaction: reaction, artist: artists[0])
        insertAllData(context: context, venue: venue, artists: artists, exhibition: exhibition,
                     artworks: artworks, user: user, capture: capture, reaction: reaction)

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: .seed)
            Log.debug("DEV seed completed.")
        } catch {
            Log.debug("DEV seed failed: \(error)")
        }
        #endif
    }

    private static func createVenue() -> Venue {
        Venue(id: "venue_seoulmuseum", name: "Seoul Museum", address: "Seoul",
              geoLat: 37.5665, geoLon: 126.9780)
    }

    private static func createArtists() -> [Artist] {
        [
            Artist(id: "artist_kim", name: "김민준", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: "artist_park", name: "박서연", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: "artist_lee", name: "이도윤", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: "artist_kong", name: "공지우", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: "artist_soo", name: "서예준", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: "artist_choi", name: "최하은", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: "artist_jung", name: "정우진", exhibitions: ["exhibition_light"], receivedReactions: [])
        ]
    }

    private static func createExhibition(venueId: String) -> Exhibition {
        Exhibition(
            id: "exhibition_light",
            title: "빛의 향연",
            descriptionText: "현대 미술에서 빛의 감각을 탐구하는 전시",
            startDate: Date().addingTimeInterval(-86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 14),
            venueId: venueId,
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
    }

    private static func createArtworks(exhibitionId: String, artists: [Artist]) -> [Artwork] {
        let artworkData: [(String, String, String)] = [
            ("artwork_light_01", "빛의 흐름", artists[0].id),
            ("artwork_light_02", "새벽의 속삭임", artists[0].id),
            ("artwork_light_03", "무한의 경계", artists[1].id),
            ("artwork_light_04", "고요한 울림", artists[2].id),
            ("artwork_light_05", "시간의 파편", artists[3].id),
            ("artwork_light_06", "영원의 순간", artists[4].id),
            ("artwork_light_07", "기억의 잔향", artists[5].id),
            ("artwork_light_08", "침묵의 시", artists[6].id),
            ("artwork_light_09", "꿈의 여정", artists[0].id),
            ("artwork_light_10", "빛나는 그림자", artists[1].id)
        ]

        return artworkData.enumerated().map { index, data in
            Artwork(id: data.0, exhibitionId: exhibitionId, title: data.1,
                   artistId: data.2, thumbnailURL: "mock_artworkImage_\(String(format: "%02d", index + 1))")
        }
    }

    private static func createCaptureAndReaction(artworkId: String, userId: String)
        -> (CapturedArtwork, Reaction) {
        let capture = CapturedArtwork(id: UUID().uuidString, artworkId: artworkId,
                                     localImagePath: "file:///tmp/mock1.jpg", createdAt: .now)
        let reaction = Reaction(id: UUID().uuidString, artworkId: artworkId, userId: userId,
                               category: ["좋아요"], comment: "빛이 멋져요", createdAt: .now)
        return (capture, reaction)
    }

    private static func setupRelationships(user: User, reaction: Reaction, artist: Artist) {
        user.sentReactions.append(reaction)
        artist.receivedReactions.append(reaction)
    }

    private static func insertAllData(context: ModelContext, venue: Venue, artists: [Artist],
                                     exhibition: Exhibition, artworks: [Artwork], user: User,
                                     capture: CapturedArtwork, reaction: Reaction) {
        context.insert(venue)
        artists.forEach { context.insert($0) }
        context.insert(exhibition)
        context.insert(exhibition1)
        context.insert(exhibition2)
        context.insert(exhibition3)
        context.insert(artwork1); context.insert(artwork2)
        context.insert(capture1)
        context.insert(capture2)
        context.insert(capture3)
        context.insert(capture4)
        context.insert(capture5)
        context.insert(capture6)
        context.insert(reaction1)

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: .seed)
            Log.debug("DEV seed completed.")
        } catch {
            Log.debug("DEV seed failed: \(error)")
        }
        #endif
        artworks.forEach { context.insert($0) }
        context.insert(user)
        context.insert(capture)
        context.insert(reaction)
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
