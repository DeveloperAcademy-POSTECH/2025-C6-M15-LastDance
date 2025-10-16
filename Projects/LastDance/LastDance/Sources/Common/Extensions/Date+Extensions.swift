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
    
    /// 짧은 날짜 형식으로 변환 (yyyy.M.d)
    func toShortDateString() -> String {
        return Date.shortDateFormatter.string(from: self)
    }
}
