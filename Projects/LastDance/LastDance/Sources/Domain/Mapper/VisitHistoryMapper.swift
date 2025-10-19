//
//  VisitHistoryMapper.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

import Foundation

enum VisitHistoryMapper {
    static func toModel(from dto: VisitorHistoriesResponseDto) -> VisitHistory? {
        // ISO8601 날짜 문자열을 Date로 변환
        let dateFormatter = ISO8601DateFormatter()
        guard let visitedDate = dateFormatter.date(from: dto.visited_at) else {
            Log.error("날짜 변환 실패: \(dto.visited_at)")
            return nil
        }

        return VisitHistory(
            id: dto.id,
            visitorId: dto.visitor_id,
            exhibitionId: dto.exhibition_id,
            visitedAt: visitedDate
        )
    }
}
