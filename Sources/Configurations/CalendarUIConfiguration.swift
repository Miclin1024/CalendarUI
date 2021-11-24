//
//  CalendarUIConfiguration.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import UIKit

internal typealias Configuration = CalendarUI.Configuration

public extension CalendarUI {
    
    /**
     The root configuration object for `CalendarUI`.
     */
    struct Configuration {
        
        public var headerConfiguration = HeaderConfiguration()
        
        public var timelineConfiguration = TimelineConfiguration()
        
        public var calendarConfiguration = CalendarConfiguration()
        
        public var headerBottomSpacing: CGFloat = 10
        
        public var backgroundColor = UIColor.clear
        
        public var contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        public init() {}
    }
}

public enum DateStyle {
    // Times should be shown in the 12 hour format
    case twelveHour

    // Times should be shown in the 24 hour format
    case twentyFourHour

    // Times should be shown according to the user's system preference.
    case system
}
