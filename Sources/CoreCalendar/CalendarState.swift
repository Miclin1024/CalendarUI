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
public final class CalendarState {
    
    /** Hashable key for identifying `CalendarState` */
    struct Key: Hashable {
        let layout: Layout
        
        let date: Date
    }
    
    public enum Layout: Hashable {
        case month, week
    }
    
    /** The active calendar layout */
    public var currentLayout: Layout
    
    /** The first moment in the current calendar layout, as a `Date`*/
    public var firstDateInMonthOrWeek: Date
    
    /** Whether the timeline view is enabled  */
    public var isTimelineEnabled: Bool = false
    
    /** The previous calendar state based on the current layout. */
    lazy var prev: CalendarState = {
        var date: Date
        if currentLayout == .week {
            date = calendar.date(byAdding: .day, value: -7,
                                 to: firstDateInMonthOrWeek)!
        } else {
            date = calendar.date(byAdding: .month, value: -1,
                                 to: firstDateInMonthOrWeek)!
        }
        return CalendarState.state(withLayout: currentLayout, date: date)
    }()
    
    /** The next calendar state based on the current layout. */
    lazy var next: CalendarState = {
        var date: Date
        if currentLayout == .week {
            date = calendar.date(byAdding: .day, value: 7,
                                 to: firstDateInMonthOrWeek)!
        } else {
            date = calendar.date(byAdding: .month, value: 1,
                                 to: firstDateInMonthOrWeek)!
        }
        return CalendarState.state(withLayout: currentLayout, date: date)
    }()
    
    var key: Key {
        return Key(layout: currentLayout, date: firstDateInMonthOrWeek)
    }
    
    private let calendar = CalendarManager.main.calendar
    
    /**
     Initialize a calendar state using the month layout.
     
     The `Date` parameter will be normalized to the first moment of the month.
     */
    private init(withMonthLayout month: Date) {
        let date = calendar.startOfMonth(for: month)
        currentLayout = .month
        firstDateInMonthOrWeek = date
    }
    
    /**
     Initialize a calendar state using the week layout.
     
     The `Date` parameter will be normalized to the first moment of the week.
     */
    private init(withWeekLayout week: Date) {
        let date = calendar.startOfWeek(for: week)
        currentLayout = .week
        firstDateInMonthOrWeek = date
    }
    
    /**
     Factory method for creating state with layout and date.
     
     Date will be normalize to the first moment in the calendar state based on layout.
     */
    public static func state(withLayout layout: Layout, date: Date) -> CalendarState {
        let key = Key(layout: layout, date: date)
        let state = CalendarManager.main.statePool[key]
        guard let state = state else {
            var newState: CalendarState
            if layout == .week {
                newState = CalendarState(withWeekLayout: date)
            } else {
                newState = CalendarState(withMonthLayout: date)
            }
            CalendarManager.main.statePool[key] = newState
            return newState
        }
        
        return state
    }
}
