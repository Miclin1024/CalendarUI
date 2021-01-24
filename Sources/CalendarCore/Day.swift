//
//  Day.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation

public struct Day: Hashable, Equatable {
    var date: Date
    
    var number: Int
    
    var isCurrentMonth: Bool
    
    var isToday: Bool = false
    
    public static func ==(lhs: Day, rhs: Day) -> Bool {
        return NSCalendar.current.compare(lhs.date, to: rhs.date, toGranularity: .nanosecond) == .orderedSame
    }
}
