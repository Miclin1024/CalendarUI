//
//  MKCalendarLayout.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public protocol MKCalendarLayout {
    
    func calendarTitle(_ calendar: MKCalendar, forDisplayState state: MKCalendar.DisplayState, selectedDays days: [Day]) -> String
    
    func edgeInset(forCalendarDisplayState state: MKCalendar.DisplayState) -> UIEdgeInsets
}

extension MKCalendarLayout {
    
    public func calendarTitle(_ calendar: MKCalendar, forDisplayState state: MKCalendar.DisplayState, selectedDays days: [Day]) -> String {
        let date = days.first?.date ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM d, y"
        return formatter.string(from: date)
    }
    
    public func edgeInset(forCalendarDisplayState state: MKCalendar.DisplayState) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}

public class MKCalendarDefaultLayout: MKCalendarLayout { }
