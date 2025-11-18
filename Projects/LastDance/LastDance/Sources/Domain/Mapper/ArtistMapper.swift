//
//  ArtistMapper.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

import Foundation

enum ArtistMapper {
    static func toModel(from dto: ArtistListItemDto) -> Artist {
        Artist(id: dto.id, uuid: "", name: dto.name)
    }
}
