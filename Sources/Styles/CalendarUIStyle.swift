//
//  CalendarUIStyle.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation
import UIKit

/**
 The root configuration class for `CalendarUI`.
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

public enum DateStyle {
    // Times should be shown in the 12 hour format
    case twelveHour
    
    // Times should be shown in the 24 hour format
    case twentyFourHour
    
    // Times should be shown according to the user's system preference.
    case system
}
