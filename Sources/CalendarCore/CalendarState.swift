//
//  CalendarState.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/29/21.
//

import Foundation

public struct CalendarState: Equatable {
    
    public static func MonthViewToday() -> CalendarState {
        return CalendarState(mode: .month, date: Date())
    }
    
    public static func WeekViewToday() -> CalendarState {
        return CalendarState(mode: .week, date: Date())
    }
    
    public private(set) var mode: MKCalendar.DisplayMode
    
    public private(set) var date: Date {
        get {
            return dateNormalized
        }
        
        set(value) {
            setNormalizedDate(usingDate: value)
        }
    }
    
    public internal(set) var isTransitioning = false
    
    private var dateNormalized: Date
    
    private mutating func setNormalizedDate(usingDate date: Date) {
        switch mode {
        case .month:
            dateNormalized = NSCalendar.current.getMonth(fromDate: date)!
        case .week:
            dateNormalized = NSCalendar.current.getFirstDayOfWeek(fromDate: date)!
        }
    }
    
    public init(mode: MKCalendar.DisplayMode, date: Date) {
        self.mode = mode
        switch mode {
        case .month:
            dateNormalized = NSCalendar.current.getMonth(fromDate: date)!
        case .week:
            dateNormalized = NSCalendar.current.getFirstDayOfWeek(fromDate: date)!
        }
    }
    
    public static func == (lhs: CalendarState, rhs: CalendarState) -> Bool {
        return lhs.date.compare(rhs.date) == .orderedSame &&
            lhs.mode == rhs.mode
    }
}

