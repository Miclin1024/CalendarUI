//
//  CalendarDayProvider.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation

/** Factory class for generating `CalendarDay` objects pertaining to a `CalendarState` */
final class CalendarDayProvider {
    
    private static let calendar = CalendarManager.calendar
    
    /**
     Returns an array of `CalendarDay` that reside within the `CalendarState`.
     */
    static func days(for calendarState: CalendarState) -> [CalendarDay] {
        let date = calendarState.firstDateInMonthOrWeek
        let layout = calendarState.layout
        
        if layout == .month {
            var result = days(preceding: calendarState)
            result.append(contentsOf: days(
                from: calendar.startOfMonth(for: date),
                through: calendar.endOfMonth(for: date))
            )
            result.append(contentsOf: days(following: calendarState))
            return result
        } else {
            return days(from: calendar.startOfWeek(for: date),
                        through: calendar.endOfWeek(for: date))
        }
    }
    
    /**
     Returns an array of `CalendarDay` that precedes the state to the beginning of the week.
     
     For example, if we were to call `days(preceding:)` with a month layout state set to December 2021, since the first day of the month is a Wednesday, calling this method returns the `CalendarDay` corresponding to the Sunday, Monday, and Tuesday right before December 1, 2021.
     */
    static func days(preceding calendarState: CalendarState) -> [CalendarDay] {
        guard calendarState.layout != .week else {
            return []
        }
        let date = calendarState.firstDateInMonthOrWeek
        let endDate = calendar.startOfMonth(for: date)
        let startDate = calendar.startOfWeek(for: endDate)
        return days(from: startDate, to: endDate)
    }
    
    /**
     Returns an array of `CalendarDay` that follows the state to the end of the week.
     
     For example, if we were to call `days(following:)` with a month layout state set to November 2021, since the last day of the month is a Tuesday, calling this method returns the `CalendarDay` corresponding to the Wednesday, Thursday, Friday, and Saturday right after November 30, 2021.
     */
    static func days(following calendarState: CalendarState) -> [CalendarDay] {
        guard calendarState.layout != .week else {
            return []
        }
        let date = calendarState.firstDateInMonthOrWeek
        let startDate = calendar.date(
            byAdding: .day,
            value: 1, to: calendar.endOfMonth(for: date))!
        let endDate = calendar.endOfWeek(for: startDate)
        return days(from: startDate, through: endDate)
    }
    
    private static func days(from fromDate: Date, through throughDate: Date) -> [CalendarDay] {
        var days = [CalendarDay]()
        var current = fromDate
        while current <= throughDate {
            days.append(CalendarDay(date: current))
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return days
    }
    
    private static func days(from fromDate: Date, to toDate: Date) -> [CalendarDay] {
        var days = [CalendarDay]()
        var current = fromDate
        while current < toDate {
            days.append(CalendarDay(date: current))
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return days
    }
}
