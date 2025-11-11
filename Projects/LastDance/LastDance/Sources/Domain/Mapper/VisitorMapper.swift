//
//  VisitorMapper.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

enum VisitorMapper {
    static func toModel(from dto: VisitorListResponseDto) -> Visitor {
        Visitor(id: dto.id, uuid: dto.uuid, name: dto.name)
    }
}
