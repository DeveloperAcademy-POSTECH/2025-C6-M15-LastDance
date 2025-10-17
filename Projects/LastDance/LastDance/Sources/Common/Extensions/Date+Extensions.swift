//
//  Date+Extensions.swift
//  LastDance
//
//  Created by 광로 on 10/15/25.
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

    /// 짧은 날짜 형식으로 변환 (yyyy.M.d)
    func toShortDateString() -> String {
        return Date.shortDateFormatter.string(from: self)
    }

    /// API 요청용 날짜 형식으로 변환 (yyyy-MM-dd)
    func toAPIDateString() -> String {
        return Date.apiDateFormatter.string(from: self)
    }
}
