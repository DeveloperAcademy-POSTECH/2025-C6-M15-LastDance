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
    var exhibitionId: Int
    var title: String
    var descriptionText: String?
    var artistId: Int?
    var thumbnailURL: String?

    @Relationship(inverse: \Exhibition.artworks)
    var exhibition: Exhibition?
    
    // 관계 역참조는 별도 선언 없이 exhibition.artworks로 관리
    init(id: Int,
         exhibitionId: Int,
         title: String,
         descriptionText: String? = nil,
         artistId: Int? = nil,
         thumbnailURL: String? = nil,
         exhibition: Exhibition? = nil
    ) {
        self.id = id
        self.exhibitionId = exhibitionId
        self.title = title
        self.descriptionText = descriptionText
        self.artistId = artistId
        self.thumbnailURL = thumbnailURL
        self.exhibition = exhibition
    }
}
