//
//  CalendarState.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/29/21.
//

import Foundation

public class CalendarState: Equatable {
    
    public static func MonthViewToday() -> CalendarState {
        return CalendarState(mode: .month, date: Date())
    }
    
    public static func WeekViewToday() -> CalendarState {
        return CalendarState(mode: .week, date: Date())
    }
    
    public private(set) var mode: DisplayMode
    
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
    
    private func setNormalizedDate(usingDate date: Date) {
        switch mode {
        case .month:
            dateNormalized = NSCalendar.current.getMonth(fromDate: date)!
        case .week:
            dateNormalized = NSCalendar.current.getFirstDayOfWeek(fromDate: date)!
        }
    }
    
    public init(mode: DisplayMode, date: Date) {
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

public enum DisplayMode {
    case month, week
}

public enum SelectionMode {
    case single, multiple
}
