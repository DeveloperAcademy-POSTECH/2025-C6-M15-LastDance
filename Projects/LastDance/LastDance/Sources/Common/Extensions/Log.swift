//
//  Logger.swift
//  CodePlay
//
//  Created by 아우신얀 on 8/11/25.
//

import Foundation
import os.log

struct Log {
    /// # Level
    /// - debug : 디버깅 로그
    /// - info : 시스템 상태 파악 로그
    /// - warning: 경고에 대한 정보 기록
    /// - fault : 실행 중 발생하는 버그
    /// - error :  심각한 오류
    
    enum Level {
        case debug
        case info
        case warning
        case error
        case fault

        fileprivate var category: String {
            switch self {
            case .debug:
                return "⌨️ DEBUG"
            case .info:
                return "ℹ️ INFO"
            case .warning:
                return "⚠️ WARNING"
            case .fault:
                return "🚫 FAULT"
            case .error:
                return "❌ ERROR"
            }
        }

        fileprivate var osLog: OSLog {
            switch self {
            case .debug:
                return OSLog.debug
            case .info:
                return OSLog.info
            case .warning:
                return OSLog.warning
            case .fault:
                return OSLog.fault
            case .error:
                return OSLog.error
            }
        }
    }

    static private func log(
        _ message: Any,
        level: Level,
        file: String,
        function: String
    ) {
        #if DEBUG
        let logger = Logger(
            subsystem: OSLog.subsystem,
            category: level.category
        )

        let logMessage = "\(level.category): [\(file)] \(function) -> \(message)"
        switch level {
        case .debug:
            logger.debug("\(logMessage, privacy: .public)")
        case .info:
            logger.info("\(logMessage, privacy: .public)")
        case .warning:
            logger.warning("\(logMessage, privacy: .private)")
        case .fault:
            logger.log("\(logMessage, privacy: .private)")
        case .error:
            logger.error("\(logMessage, privacy: .private)")
        }
        #endif
    }
}

// MARK: - extension
extension OSLog {
    static let subsystem = Bundle.main.bundleIdentifier!
    static let fault = OSLog(subsystem: subsystem, category: "Fault")
    static let debug = OSLog(subsystem: subsystem, category: "Debug")
    static let warning = OSLog(subsystem: subsystem, category: "Warning")
    static let info = OSLog(subsystem: subsystem, category: "Info")
    static let error = OSLog(subsystem: subsystem, category: "Error")
}

extension Log {
    /**
     # debug
     - Note : 개발 중 코드 디버깅 시 사용할 수 있는 유용한 정보
     */
    static func debug(
        _ message: Any,
        file: String = #fileID,
        function: String = #function
    ) {
        log(message, level: .debug, file: file, function: function)
    }

    /**
     # info
     - Note : 문제 해결시 활용할 수 있는, 도움이 되지만 필수적이지 않은 정보
     */
    static func info(
        _ message: Any,
        file: String = #fileID,
        function: String = #function
    ) {
        log(message, level: .info, file: file, function: function)
    }

    /**
     # warning
     - Note : 경고에 대한 정보, 잠재적으로 문제가 될 수 있는 상황
     */
    static func warning(
        _ message: Any,
        file: String = #fileID,
        function: String = #function
    ) {
        log(message, level: .warning, file: file, function: function)
    }

    /**
     # fault
     - Note : 실행 중 발생하는 버그나 잘못된 동작
     */
    static func fault(
        _ message: Any,
        file: String = #fileID,
        function: String = #function
    ) {
        log(message, level: .fault, file: file, function: function)
    }

    /**
     # error
     - Note : 코드 실행 중 나타난 에러
     */
    static func error(
        _ message: Any,
        file: String = #fileID,
        function: String = #function
    ) {
        log(message, level: .error, file: file, function: function)
    }
}
