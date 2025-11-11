//
//  VisitHistoryMapper.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

import Foundation

enum VisitHistoryMapper {
  static func toModel(from dto: VisitorHistoriesResponseDto) -> VisitHistory? {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    guard let visitedDate = dateFormatter.date(from: dto.visited_at) else {
      Log.fault("날짜 변환 실패: \(dto.visited_at)")
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
