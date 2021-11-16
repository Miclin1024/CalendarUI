//
//  Calendar+Utilities.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation

extension Calendar {
       
    /**
     Returns the first moment of a given month.
     */
    func startOfMonth(for date: Date) -> Date {
        let components = self.dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
    
    /**
     Returns the first moment of a given week.
     */
    func startOfWeek(for date: Date) -> Date {
        let components = self.dateComponents([.year, .yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)!
    }
    
    /**
     Returns the start of the last day of the given month.
     */
    func endOfMonth(for date: Date) -> Date {
        let month = startOfMonth(for: date)
        let firstDayNextMonth = self.date(byAdding: .month, value: 1, to: month)!
        return self.date(byAdding: .day, value: -1, to: firstDayNextMonth)!
    }
    
    /**
     Returns the start of the last day of the given week.
     */
    func endOfWeek(for date: Date) -> Date {
        let week = startOfWeek(for: date)
        return self.date(byAdding: .day, value: 6, to: week)!
    }
}
