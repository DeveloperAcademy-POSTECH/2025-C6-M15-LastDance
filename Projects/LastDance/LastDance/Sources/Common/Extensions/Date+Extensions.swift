//
//  Date+Extensions.swift
//  LastDance
//
//  Created by 광로, 신얀 on 10/15/25.
//

import Foundation

extension Date {
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        return formatter
    }()

    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    private static let isoFormatter = ISO8601DateFormatter()

    /// API 요청용 날짜 형식으로 변환 (yyyy-MM-dd)
    func toAPIDateString() -> String {
        return Date.apiDateFormatter.string(from: self)
    }

    /// ISO8601 String을 표시용 날짜 형식으로 변환 (yyyy년 M월 d일(E))
    static func formatDisplayDate(from isoString: String) -> String {
        if let date = isoFormatter.date(from: isoString) {
            return displayDateFormatter.string(from: date)
        }
        return isoString
    }
    
    /// ISO8601 String을 표시용 날짜 형식으로 변환 (yyyy.M. d)
    static func formatShortDate(from isoString: String) -> String {
        if let date = isoFormatter.date(from: isoString) {
            return shortDateFormatter.string(from: date)
        }
        return isoString
    }

    /// ISO8601 String 두 개로 날짜 범위 포맷팅
    static func formatDateRange(start: String, end: String) -> String {
        let startString = formatDisplayDate(from: start)
        let endString = formatDisplayDate(from: end)
        return "\(startString)~ \(endString)"
    }

    /// ISO8601 String을 API 날짜 형식으로 변환 (yyyy-MM-dd)
    static func formatAPIDate(from isoString: String) -> String {
        // ISO8601 형식 파싱 시도
        if let date = isoFormatter.date(from: isoString) {
            return apiDateFormatter.string(from: date)
        }

        // 파싱 실패 시, 정규표현식으로 날짜 부분만 추출
        let pattern = "^(\\d{4}-\\d{2}-\\d{2})"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: isoString, range: NSRange(isoString.startIndex..., in: isoString)),
           let range = Range(match.range, in: isoString) {
            return String(isoString[range])
        }
        return isoString
    }
}
