//
//  TimelineStyle.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/16/21.
//

import UIKit

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
