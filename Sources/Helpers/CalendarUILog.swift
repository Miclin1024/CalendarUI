//
//  CalendarUILog.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/17/21.
//

import Foundation

class CalendarUILog {
    
    enum Level: Int, Comparable {
        
        case info = 1
        case warning = 2
        case error = 3
        
        fileprivate var prefix: String {
            switch self {
            case .info:
                return "[CalendarUI] Info: "
            case .warning:
                return "[CalendarUI] Warning: "
            case .error:
                return "[CalendarUI] Error: "
            }
        }
        
        static func < (lhs: CalendarUILog.Level, rhs: CalendarUILog.Level) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    static var logLevel: Level = {
        var levelRaw = UserDefaults.standard.integer(forKey: "CalendarUIUserLogLevel")
        return .init(rawValue: levelRaw) ?? .warning
    }()
    
    static func send(_ message: String, level: Level) {
        if level >= logLevel {
            print(level.prefix + message)
        }
    }
}
