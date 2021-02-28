//
//  Calendar+DateUtils.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation

extension Calendar {
    func datesBetween(_ startDate: Date, through endDate: Date, byAdding component: Calendar.Component, value: Int) -> [Date] {
        let calendar = NSCalendar.current
        
        let normalizedStartDate = startOfDay(for: startDate)
        let normalizedEndDate = startOfDay(for: endDate)
        
        guard calendar.compare(normalizedStartDate, to: normalizedEndDate, toGranularity: .nanosecond) == .orderedAscending else {
            print("WARNING: Start date \(startDate) and end date \(endDate) are not in ascending order")
            return []
        }
        
        var dates: [Date] = [normalizedStartDate]
        var currDates = normalizedStartDate
        
        repeat {
            currDates = date(byAdding: component, value: value, to: currDates)!
            dates.append(currDates)
        } while !isDate(currDates, inSameDayAs: normalizedEndDate)
        
        return dates
    }
    
    func getMonth(fromDate date: Date) -> Date? {
        let comp = self.dateComponents([.year, .month], from: date)
        return self.date(from: comp)
    }
    
    func getFirstDayOfWeek(fromDate date: Date) -> Date? {
        let comp = self.dateComponents([.year, .yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: comp)
    }
    
    func getLastDayInMonth(fromDate date: Date) -> Date? {
        guard let month = getMonth(fromDate: date) else { return nil }
        guard let firstDayNextMonth = self.date(byAdding: .month, value: 1, to: month) else { return nil }
        return self.date(byAdding: .day, value: -1, to: firstDayNextMonth)
    }
    
    func getLastDayOfWeek(fromDate date: Date) -> Date? {
        guard let week = getFirstDayOfWeek(fromDate: date) else { return nil}
        return self.date(byAdding: .day, value: 6, to: week)
    }
}
