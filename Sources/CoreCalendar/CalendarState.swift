//
//  CalendarState.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation

/**
 The current display state of the calendar UI.
 
 Includes information such as the active layout, the month/week that is being displayed, and if the timeline view is enabled.
 */
public struct CalendarState: Hashable {
    
    /**
     Return whether the two states have different layout but are in in the same month.
     
     This function is used to determine whether a state update should happen in place on the page.
     */
    static func sameMonthWithDifferentLayout(_ state1: CalendarState, _ state2: CalendarState) -> Bool {
        guard state1.layout != state2.layout else { return false }
        
        let calendar = CalendarManager.calendar
        return calendar
            .startOfMonth(for: state1.firstDateInMonthOrWeek) == calendar
            .startOfMonth(for: state2.firstDateInMonthOrWeek)
    }
    
    public enum Layout: Int, Hashable {
        case month = 0
        case week = 1
    }
    
    /** The active calendar layout */
    public var layout: Layout
    
    /** The first moment in the current calendar layout, as a `Date`*/
    public var firstDateInMonthOrWeek: Date
    
    /** The previous calendar state based on the current layout. */
    var prev: CalendarState {
        var date: Date
        if layout == .week {
            date = CalendarManager.calendar
                .date(byAdding: .day,
                      value: -7, to: firstDateInMonthOrWeek)!
        } else {
            date = CalendarManager.calendar
                .date(byAdding: .month,
                      value: -1, to: firstDateInMonthOrWeek)!
        }
        return CalendarState(withLayout: layout, date: date)
    }
    
    /** The next calendar state based on the current layout. */
    var next: CalendarState {
        var date: Date
        if layout == .week {
            date = CalendarManager.calendar
                .date(byAdding: .day, value: 7, to: firstDateInMonthOrWeek)!
        } else {
            date = CalendarManager.calendar
                .date(byAdding: .month,
                      value: 1, to: firstDateInMonthOrWeek)!
        }
        return CalendarState(withLayout: layout, date: date)
    }
    
    /** The range of dates that the state contains*/
    var dateRange: ClosedRange<Date> {
        let calendar = CalendarManager.calendar
        let startRange = firstDateInMonthOrWeek
        let endRange = layout == .week ?
            calendar.endOfWeek(for: startRange) :
            calendar.endOfMonth(for: startRange)
        return startRange...endRange
    }
    
    /**
     Initialize a calendar state using the month layout.
     
     The `Date` parameter will be normalized to the first moment of the month.
     */
    private init(withMonthLayout month: Date) {
        let date = CalendarManager.calendar
            .startOfMonth(for: month)
        layout = .month
        firstDateInMonthOrWeek = date
    }
    
    /**
     Initialize a calendar state using the week layout.
     
     The `Date` parameter will be normalized to the first moment of the week.
     */
    private init(withWeekLayout week: Date) {
        let date = CalendarManager.calendar
            .startOfWeek(for: week)
        layout = .week
        firstDateInMonthOrWeek = date
    }
    
    /**
     Initialize a calendar state with layout and date.
     
     Date will be normalize to the first moment in the calendar state based on layout.
     */
    public init(withLayout layout: Layout, date: Date) {
        switch layout {
        case .month:
            self.init(withMonthLayout: date)
        case .week:
            self.init(withWeekLayout: date)
        }
    }
    
    public static func == (lhs: CalendarState, rhs: CalendarState) -> Bool {
        return lhs.layout == rhs.layout
        && lhs.firstDateInMonthOrWeek == rhs.firstDateInMonthOrWeek
    }
}
