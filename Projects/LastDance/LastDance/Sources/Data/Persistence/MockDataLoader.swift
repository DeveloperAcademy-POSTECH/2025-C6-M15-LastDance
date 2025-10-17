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
        let exhibitions = createExhibition(venueId: venue.id)
        let artworks = createArtworks(exhibitionId: exhibitions[0].id, artists: artists)
        let user = User(role: "Visitor")
        let (capture, reaction) = createCaptureAndReaction(artworkId: artworks[0].id, userId: user.id.uuidString)

        // 샘플 Artworks
        let artwork1 = Artwork(
            id: 101,
            exhibitionId: exhibitions[0].id,
            title: "Light #1",
            artistId: artists[0].id,
            thumbnailURL: "mock_artworkImage_01"
        )
        let artwork2 = Artwork(
            id: 102,
            exhibitionId: exhibitions[0].id,
            title: "Light #2",
            artistId: artists[0].id,
            thumbnailURL: "mock_artworkImage_02"
        )
        exhibitions[0].artworks = [artwork1, artwork2]

        // 임시 캡처/반응 (6개의 캡처 생성)
        let capture1 = CapturedArtwork(
            id: 201,
            artworkId: artwork1.id,
            localImagePath: "file:///tmp/mock1.jpg",
            createdAt: .now.addingTimeInterval(-300)
        )
        let capture2 = CapturedArtwork(
            id: 202,
            artworkId: artwork1.id,
            localImagePath: "mock_artworkImage_01",
            createdAt: .now.addingTimeInterval(-200)
        )
        let capture3 = CapturedArtwork(
            id: 203,
            artworkId: artwork2.id,
            localImagePath: "mock_artworkImage_02",
            createdAt: .now.addingTimeInterval(-100)
        )
        let capture4 = CapturedArtwork(
            id: 204,
            artworkId: artwork2.id,
            localImagePath: "mock_artworkImage_01",
            createdAt: .now
        )
        let capture5 = CapturedArtwork(
            id: 205,
            artworkId: artwork2.id,
            localImagePath: "mock_artworkImage_01",
            createdAt: .now
        )
        let capture6 = CapturedArtwork(
            id: 206,
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
        context.insert(artwork1); context.insert(artwork2)
        context.insert(capture1)
        context.insert(capture2)
        context.insert(capture3)
        context.insert(capture4)
        context.insert(capture5)
        context.insert(capture6)
        context.insert(reaction1)
        
        setupRelationships(user: user, reaction: reaction, artist: artists[0])
        insertAllData(context: context, venue: venue, artists: artists, exhibitions: exhibitions,
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

    static func createArtists() -> [Artist] {
        [
            Artist(id: 1, name: "김민준", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: 2, name: "박서연", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: 3, name: "이도윤", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: 4, name: "공지우", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: 5, name: "서예준", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: 6, name: "최하은", exhibitions: ["exhibition_light"], receivedReactions: []),
            Artist(id: 7, name: "정우진", exhibitions: ["exhibition_light"], receivedReactions: [])
        ]
    }

    
    private static func createExhibition(venueId: String) -> [Exhibition] {
        [
            Exhibition(
                id: "exhibition_light",
                title: "빛의 향연",
                descriptionText: "현대 미술에서 빛의 감각을 탐구하는 전시",
                startDate: Date().addingTimeInterval(-86400 * 3),
                endDate: Date().addingTimeInterval(86400 * 14),
                venueId: venueId,
                coverImageName: "mock_exhibitionCoverImage"
            ),
            Exhibition(
                id: "exhibition_02",
                title: "조샘초이 : 기억의 지층, 경계를 넘는 시선",
                descriptionText: "조샘초이 작가의 개인전",
                startDate: Date().addingTimeInterval(-86400 * 8),
                endDate: Date().addingTimeInterval(86400 * 15),
                venueId: venueId,
                coverImageName: "mock_exhibitionCoverImage"
            ),
            Exhibition(
                id: "exhibition_03",
                title: "기증작가 상설전: 박대성 소산수목",
                descriptionText: "박대성 작가의 기증 작품 전시",
                startDate: Date().addingTimeInterval(-86400 * 6),
                endDate: Date().addingTimeInterval(86400 * 12),
                venueId: venueId,
                coverImageName: "mock_artworkImage_02"
            ),
            Exhibition(
                id: "exhibition_04",
                title: "清年! 青年! 請年! - 맑고 푸른 그대에게 청한다",
                descriptionText: "젊은 작가들의 작품 전시",
                startDate: Date().addingTimeInterval(-86400 * 10),
                endDate: Date().addingTimeInterval(86400 * 20),
                venueId: venueId,
                coverImageName: "mock_artworkImage_01"
            )
        ]
    }


    private static func createArtworks(exhibitionId: String, artists: [Artist]) -> [Artwork] {
        let artworkData: [(Int, String, Int)] = [
            (1, "빛의 흐름", artists[0].id),
            (2, "새벽의 속삭임", artists[0].id),
            (3, "무한의 경계", artists[1].id),
            (4, "고요한 울림", artists[2].id),
            (5, "시간의 파편", artists[3].id),
            (6, "영원의 순간", artists[4].id),
            (7, "기억의 잔향", artists[5].id),
            (8, "침묵의 시", artists[6].id),
            (9, "꿈의 여정", artists[0].id),
            (10, "빛나는 그림자", artists[1].id)
        ]

        return artworkData.map { data in
            Artwork(id: data.0, exhibitionId: exhibitionId, title: data.1,
                   artistId: data.2, thumbnailURL: "mock_artworkImage_\(String(format: "%02d", data.0))")
        }
    }

    private static func createCaptureAndReaction(artworkId: Int, userId: String)
        -> (CapturedArtwork, Reaction) {
        let capture = CapturedArtwork(id: 200, artworkId: artworkId,
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
                                     exhibitions: [Exhibition], artworks: [Artwork], user: User,
                                     capture: CapturedArtwork, reaction: Reaction) {
        context.insert(venue)
        artists.forEach { context.insert($0) }
        exhibitions.forEach { context.insert($0) }
        artworks.forEach { context.insert($0) }
        context.insert(user)
        context.insert(capture)
        context.insert(reaction)
        
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: .seed)
            Log.debug("DEV seed completed.")
        } catch {
            Log.debug("DEV seed failed: \(error)")
        }
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
