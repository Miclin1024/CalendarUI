//
//  CalendarUIStyle.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation
import UIKit

/**
 Style configuration class for `CalendarUI`.
 */
public struct CalendarUIStyle {
    public var headerStyle = HeaderStyle()
    public var timelineStyle = TimelineStyle()
    public var calendarStyle = CalendarStyle()
    
    public var headerBottomSpacing: CGFloat = 10
    public var backgroundColor = UIColor.clear
    public var contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    public init() {}
}

public struct CalendarStyle {
    public var dayCellStyle = DayCellStyle()
    public var backgroundColor = UIColor.clear
    public var allowMultipleSelection = false
    public init() {}
}

public struct DayCellStyle {
    public var textColor = UIColor.label
    public var inactiveTextColor = UIColor.secondaryLabel
    public var selectedBackgroundColor = UIColor.systemBlue
    public var selectedTextColor = UIColor.white
    public var todayBackgroundColor = UIColor.systemRed
    public var todayTextColor = UIColor.white
    public var font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    public init() {}
}

public struct TimelineStyle {
    public var allDayStyle = AllDayViewStyle()
    public var timeIndicator = CurrentTimeIndicatorStyle()
    public var timeColor = UIColor.secondaryLabel
    public var separatorColor = UIColor.separator
    public var backgroundColor = UIColor.clear
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
    public var color = UIColor.systemRed
    public var font = UIFont.systemFont(ofSize: 11)
    public var dateStyle : DateStyle = .system
    public init() {}
}

public struct AllDayViewStyle {
    public var backgroundColor: UIColor = UIColor.clear
    public var allDayFont = UIFont.systemFont(ofSize: 12.0)
    public var allDayColor: UIColor = UIColor.label
    public init() {}
}

public enum DateStyle {
    // Times should be shown in the 12 hour format
    case twelveHour
    
    // Times should be shown in the 24 hour format
    case twentyFourHour
    
    // Times should be shown according to the user's system preference.
    case system
}
