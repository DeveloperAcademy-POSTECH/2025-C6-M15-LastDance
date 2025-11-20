//
//  ArtistMapper.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

import Foundation

enum ArtistMapper {
    /// 작가 dto를 Model로 변환
    static func toModel(from dto: ArtistListItemDto) -> Artist {
        Artist(id: dto.id, uuid: "", name: dto.name)
    }

    /// 작가 코드 dto를 Model로 변환
    static func toArtistCodeModel(from dto: ArtistCodeResponseDto) -> ArtistCode {
        ArtistCode(
            id: dto.id,
            uuid: dto.uuid,
            name: dto.name,
            bio: dto.bio,
            email: dto.email
        )
    }
}
