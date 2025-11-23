//
//  ArtworkMapper.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

enum ArtworkMapper {
    /// ArtworkDetail DTO를 Reaction Model로 변환
    static func mapDtoToModel(_ dto: ArtworkDetailResponseDto, exhibitionId: Int) -> Artwork {
        return Artwork(
            id: dto.id,
            exhibitionId: exhibitionId,
            title: dto.title,
            descriptionText: dto.description,
            artistId: dto.artist_id,
            thumbnailURL: dto.thumbnail_url
        )
    }

    /// AppClip에서 전시 ID 없이 잠깐 쓸 때 쓰는 버전
    static func mapDtoToModel(_ dto: ArtworkDetailResponseDto) -> Artwork {
        Artwork(
            id: dto.id,
            exhibitionId: 0,
            title: dto.title,
            descriptionText: dto.description,
            artistId: dto.artist_id,
            thumbnailURL: dto.thumbnail_url
        )
    }
}
