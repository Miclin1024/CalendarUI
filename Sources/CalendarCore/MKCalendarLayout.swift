//
//  MKCalendarLayout.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public protocol MKCalendarLayout {
    
    func calendarTitle(_ calendar: MKCalendar, forCalendarState state: CalendarState, selectedDays days: [Day]) -> String
    
    var timelineHuggingHeight: CGFloat { get set }
}

public class MKCalendarDefaultLayout: MKCalendarLayout {
    
    public func calendarTitle(_ calendar: MKCalendar, forCalendarState state: CalendarState, selectedDays days: [Day]) -> String {
        let dateSelected = days.first?.date ?? Date()
        let startRange = state.date
        let endRange = state.mode == .week ?
        calendar.calendar.date(byAdding: .day, value: 7, to: startRange)! :
            calendar.calendar.date(byAdding: .month, value: 1, to: startRange)!
        let range = startRange ... endRange
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if range.contains(dateSelected) {
            formatter.dateFormat = "MMMM d, y"
            return formatter.string(from: dateSelected)
        } else {
            formatter.dateFormat = "MMMM, y"
            return formatter.string(from: startRange)
        }
    }
    
    public var timelineHuggingHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    
    public init(){}
}
