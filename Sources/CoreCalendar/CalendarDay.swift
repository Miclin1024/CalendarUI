//
//  CalendarDay.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation

/**
 Data model for a single calendar cell.
 
 Two `CalendarDay` are considered equal when their `date` property
 are the same.
 */
public struct CalendarDay: Hashable {
    
    /** Underlying `Date` of the day the object represents. */
    public var date: Date
    
    public var isToday: Bool {
        let calendar = CalendarManager.calendar
        let today = calendar.startOfDay(for: .now)
        return date.compare(today) == .orderedSame
    }
    
//    public var isInCurrentMonth
//        public var events: [EventDescriptor] = []
}

extension CalendarDay: CustomStringConvertible {
    public var description: String {
        return "{CalendarDay \(date), isToday: \(isToday)}"
    }
}
