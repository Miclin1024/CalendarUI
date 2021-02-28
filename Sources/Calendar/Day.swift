//
//  Day.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation

public struct Day: Hashable, Equatable {
    public var date: Date
    
    public var number: Int
    
    public var isCurrentMonth: Bool
    
    public var isToday: Bool = false
    
    public static func ==(lhs: Day, rhs: Day) -> Bool {
        return NSCalendar.current.compare(lhs.date, to: rhs.date, toGranularity: .nanosecond) == .orderedSame
    }
}
