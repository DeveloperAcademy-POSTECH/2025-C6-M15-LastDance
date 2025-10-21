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
        let visitor = Visitor(id: 0, uuid: "aaaaa")
        let (capture, reaction) = createCaptureAndReaction(artworkId: artworks[0].id, visitorId: visitor.id)

        let (artwork1, artwork2) = createSampleArtworks(exhibitionId: exhibitions[0].id, artistId: artists[0].id)
        exhibitions[0].artworks = [artwork1, artwork2]

        let captures = createSampleCaptures(artwork1: artwork1, artwork2: artwork2)
        let reactions = createSampleReactions(artwork1: artwork1, visitorId: visitor.id)

        insertSampleData(context: context, artwork1: artwork1, artwork2: artwork2, captures: captures, reactions: reactions)
        setupRelationships(visitor: visitor, reaction: reaction, artist: artists[0])
        insertAllData(context: context, venue: venue, artists: artists, exhibitions: exhibitions,
                     artworks: artworks, visitor: visitor, capture: capture, reaction: reaction)

        saveSeedData(context: context)
        #endif
    }

    private static func createSampleArtworks(exhibitionId: Int, artistId: Int) -> (Artwork, Artwork) {
        let artwork1 = Artwork(
            id: 11,
            exhibitionId: exhibitionId,
            title: "Light #1",
            artistId: artistId,
            thumbnailURL: "mock_artworkImage_01"
        )
        let artwork2 = Artwork(
            id: 12,
            exhibitionId: exhibitionId,
            title: "Light #2",
            artistId: artistId,
            thumbnailURL: "mock_artworkImage_02"
        )
        return (artwork1, artwork2)
    }

    private static func createSampleCaptures(artwork1: Artwork, artwork2: Artwork) -> [CapturedArtwork] {
        return [
            CapturedArtwork(
                id: 2,
                artworkId: artwork1.id,
                localImagePath: "file:///tmp/mock1.jpg",
                createdAt: .now.addingTimeInterval(-300)
            ),
            CapturedArtwork(
                id: 3,
                artworkId: artwork1.id,
                localImagePath: "mock_artworkImage_01",
                createdAt: .now.addingTimeInterval(-200)
            ),
            CapturedArtwork(
                id: 4,
                artworkId: artwork2.id,
                localImagePath: "mock_artworkImage_02",
                createdAt: .now.addingTimeInterval(-100)
            ),
            CapturedArtwork(
                id: 5,
                artworkId: artwork2.id,
                localImagePath: "mock_artworkImage_01",
                createdAt: .now
            ),
            CapturedArtwork(
                id: 6,
                artworkId: artwork2.id,
                localImagePath: "mock_artworkImage_01",
                createdAt: .now
            ),
            CapturedArtwork(
                id: 7,
                artworkId: artwork2.id,
                localImagePath: "mock_artworkImage_02",
                createdAt: .now
            )
        ]
    }

    private static func createSampleReactions(artwork1: Artwork, visitorId: Int) -> [Reaction] {
        return [
            Reaction(
                id: UUID().uuidString,
                artworkId: artwork1.id,
                visitorId: visitorId,
                category: ["좋아요"],
                comment: "빛이 멋져요",
                createdAt: ""
            ),
            Reaction(
                id: UUID().uuidString,
                artworkId: artwork1.id,
                visitorId: visitorId,
                category: ["강한 메시지가 느껴져요", "생각하게 만드는"],
                comment: "마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다",
                createdAt: ""
            ),
            Reaction(
                id: UUID().uuidString,
                artworkId: artwork1.id,
                visitorId: visitorId,
                category: ["감동적이에요"],
                comment: "색감과 구도가 인상적입니다.",
                createdAt: ""
            )
        ]
    }

    private static func insertSampleData(
        context: ModelContext,
        artwork1: Artwork,
        artwork2: Artwork,
        captures: [CapturedArtwork],
        reactions: [Reaction]
    ) {
        context.insert(artwork1)
        context.insert(artwork2)
        captures.forEach { context.insert($0) }
        reactions.forEach { context.insert($0) }
    }

    private static func saveSeedData(context: ModelContext) {
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: .seed)
            Log.debug("DEV seed completed.")
        } catch {
            Log.debug("DEV seed failed: \(error)")
        }
    }

    private static func createVenue() -> Venue {
        Venue(id: 1, name: "Seoul Museum", address: "Seoul",
              geoLat: 37.5665, geoLon: 126.9780)
    }

    static func createArtists() -> [Artist] {
        [
            Artist(id: 1, name: "김민준", exhibitions: [3], receivedReactions: []),
            Artist(id: 2, name: "박서연", exhibitions: [3], receivedReactions: []),
            Artist(id: 3, name: "이도윤", exhibitions: [3], receivedReactions: []),
            Artist(id: 4, name: "공지우", exhibitions: [3], receivedReactions: []),
            Artist(id: 5, name: "서예준", exhibitions: [3], receivedReactions: []),
            Artist(id: 6, name: "최하은", exhibitions: [3], receivedReactions: []),
            Artist(id: 7, name: "정우진", exhibitions: [3], receivedReactions: [])
        ]
    }

    
    private static func createExhibition(venueId: Int) -> [Exhibition] {
        let isoFormatter = ISO8601DateFormatter()

        return [
            Exhibition(
                id: 1,
                title: "빛의 향연",
                descriptionText: "현대 미술에서 빛의 감각을 탐구하는 전시",
                startDate: isoFormatter.string(from: Date().addingTimeInterval(-86400 * 3)),
                endDate: isoFormatter.string(from: Date().addingTimeInterval(86400 * 14)),
                venueId: venueId,
                coverImageName: "mock_exhibitionCoverImage",
                createdAt: isoFormatter.string(from: Date()),
                updatedAt: nil
            ),
            Exhibition(
                id: 2,
                title: "조샘초이 : 기억의 지층, 경계를 넘는 시선",
                descriptionText: "조샘초이 작가의 개인전",
                startDate: isoFormatter.string(from: Date().addingTimeInterval(-86400 * 8)),
                endDate: isoFormatter.string(from: Date().addingTimeInterval(86400 * 15)),
                venueId: venueId,
                coverImageName: "mock_exhibitionCoverImage",
                createdAt: isoFormatter.string(from: Date()),
                updatedAt: nil
            ),
            Exhibition(
                id: 3,
                title: "기증작가 상설전: 박대성 소산수목",
                descriptionText: "박대성 작가의 기증 작품 전시",
                startDate: isoFormatter.string(from: Date().addingTimeInterval(-86400 * 6)),
                endDate: isoFormatter.string(from: Date().addingTimeInterval(86400 * 12)),
                venueId: venueId,
                coverImageName: "mock_artworkImage_02",
                createdAt: isoFormatter.string(from: Date()),
                updatedAt: nil
            ),
            Exhibition(
                id: 4,
                title: "清年! 青年! 請年! - 맑고 푸른 그대에게 청한다",
                descriptionText: "젊은 작가들의 작품 전시",
                startDate: isoFormatter.string(from: Date().addingTimeInterval(-86400 * 10)),
                endDate: isoFormatter.string(from: Date().addingTimeInterval(86400 * 20)),
                venueId: venueId,
                coverImageName: "mock_artworkImage_01",
                createdAt: isoFormatter.string(from: Date()),
                updatedAt: nil
            )
        ]
    }


    private static func createArtworks(exhibitionId: Int, artists: [Artist]) -> [Artwork] {
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

    private static func createCaptureAndReaction(artworkId: Int, visitorId: Int)
        -> (CapturedArtwork, Reaction) {
        let capture = CapturedArtwork(id: 200, artworkId: artworkId,
                                     localImagePath: "file:///tmp/mock1.jpg", createdAt: .now)
        let reaction = Reaction(id: UUID().uuidString, artworkId: artworkId, visitorId: visitorId,
                               category: ["좋아요"], comment: "빛이 멋져요", createdAt: "")
        return (capture, reaction)
    }

    private static func setupRelationships(visitor: Visitor, reaction: Reaction, artist: Artist) {
        visitor.sentReactions.append(reaction)
        artist.receivedReactions.append(reaction)
    }

    private static func insertAllData(context: ModelContext, venue: Venue, artists: [Artist],
                                     exhibitions: [Exhibition], artworks: [Artwork], visitor: Visitor,
                                     capture: CapturedArtwork, reaction: Reaction) {
        context.insert(venue)
        artists.forEach { context.insert($0) }
        exhibitions.forEach { context.insert($0) }
        artworks.forEach { context.insert($0) }
        context.insert(visitor)
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
        _ = try? ctx.delete(model: Visitor.self)
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
