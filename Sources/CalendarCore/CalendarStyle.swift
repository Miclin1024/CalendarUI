//
//  CalendarStyle.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public enum DateStyle {
    // Times should be shown in the 12 hour format
    case twelveHour
    
    // Times should be shown in the 24 hour format
    case twentyFourHour
    
    // Times should be shown according to the user's system preference.
    case system
}

public struct MKCalendarStyle {
    public var header = HeaderStyle()
    public var timeline = TimelineStyle()
    public var calendar = CalendarViewStyle()
    
    public var headerBottomPadding: CGFloat = 10
    public var backgroundColor = SystemColors.clear
    
    public init() {}
}

public struct HeaderStyle {
    public var symbolType: WeekdaySymbolType = .veryshort
    public var labelColor = SystemColors.secondaryLabel
    public var accentColor = SystemColors.systemBlue
    public var titleColor = SystemColors.label
    public var titleBottomPadding: CGFloat = 15.0
    public var titleFont = UIFont.systemFont(ofSize: 15, weight: .bold)
    public init() {}
}

public struct CalendarViewStyle {
    public var dayCellStyle = DayCellStyle()
    public var backgroundColor = SystemColors.clear
    public var allowMultipleSelection = false
    public init() {}
}

public struct DayCellStyle {
    public var textColor = SystemColors.label
    public var inactiveTextColor = SystemColors.secondaryLabel
    public var selectedBackgroundColor = SystemColors.systemBlue
    public var selectedTextColor = SystemColors.systemWhite
    public var todayBackgroundColor = SystemColors.systemRed
    public var todayTextColor = SystemColors.systemWhite
    public var font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    public init() {}
}

public struct TimelineStyle {
    public var allDayStyle = AllDayViewStyle()
    public var timeIndicator = CurrentTimeIndicatorStyle()
    public var timeColor = SystemColors.secondaryLabel
    public var separatorColor = SystemColors.systemSeparator
    public var backgroundColor = SystemColors.clear
    public var font = UIFont.boldSystemFont(ofSize: 11)
    public var dateStyle : DateStyle = .system
    public var eventsWillOverlap: Bool = false
    public var minimumEventDurationInMinutesWhileEditing: Int = 30
    public var splitMinuteInterval: Int = 15
    public var verticalDiff: CGFloat = 50
    public var verticalInset: CGFloat = 10
    public var leadingInset: CGFloat = 53
    public var eventGap: CGFloat = 0
    public init() {}
}

public struct CurrentTimeIndicatorStyle {
    public var color = SystemColors.systemRed
    public var font = UIFont.systemFont(ofSize: 11)
    public var dateStyle : DateStyle = .system
    public init() {}
}

public struct AllDayViewStyle {
    public var backgroundColor: UIColor = SystemColors.clear
    public var allDayFont = UIFont.systemFont(ofSize: 12.0)
    public var allDayColor: UIColor = SystemColors.label
    public init() {}
}

public enum WeekdaySymbolType {
    case normal, short, veryshort
    case custom(value: [String])
}
