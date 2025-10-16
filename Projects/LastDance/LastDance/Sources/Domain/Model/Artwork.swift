//
//  Artwork.swift
//  LastDance
//
//  Created by 배현진 on 10/9/25.
//

import Foundation
import SwiftData

@Model
final class Artwork {
    @Attribute(.unique) var id: Int
    var exhibitionId: String
    var title: String
    var artistId: Int?
    var thumbnailURL: String?

    // 관계 역참조는 별도 선언 없이 exhibition.artworks로 관리
    init(id: Int,
         exhibitionId: String,
         title: String,
         artistId: Int? = nil,
         thumbnailURL: String? = nil) {
        self.id = id
        self.exhibitionId = exhibitionId
        self.title = title
        self.artistId = artistId
        self.thumbnailURL = thumbnailURL
    }
}
