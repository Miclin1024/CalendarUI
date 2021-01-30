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
    
    func edgeInset(forCalendarState state: CalendarState) -> UIEdgeInsets
    
//    func calendarHeight(_ calendar: MKCalendar, forDisplayState state: MKCalendar.DisplayState, isTimelineHidden: Bool) -> CGFloat
    
    var timelineHuggingHeight: CGFloat { get }
}

public class MKCalendarDefaultLayout: MKCalendarLayout {
    
    public func calendarTitle(_ calendar: MKCalendar, forCalendarState state: CalendarState, selectedDays days: [Day]) -> String {
        let date = days.first?.date ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM d, y"
        return formatter.string(from: date)
    }
    
    public func edgeInset(forCalendarState state: CalendarState) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    public var timelineHuggingHeight: CGFloat = UIScreen.main.bounds.height * 0.6
}
