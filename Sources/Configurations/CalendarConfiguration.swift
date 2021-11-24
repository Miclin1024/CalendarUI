//
//  CalendarConfiguration.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/16/21.
//

import UIKit

public extension CalendarUI.Configuration {
    
    struct CalendarConfiguration {
        
        public var backgroundColor = UIColor.clear
        
        public var allowMultipleSelection = false
        
        public var textColor = UIColor.label
        
        public var inactiveTextColor = UIColor.secondaryLabel
        
        public var selectedBackgroundColor = UIColor.systemBlue
        
        public var selectedTextColor = UIColor.white
        
        public var todayBackgroundColor = UIColor.systemRed
        
        public var todayTextColor = UIColor.white
        
        public var font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        public var interCellSpacing = CGFloat(5.0)
        
        public var aspectRatio = CGFloat(1.0)
        
        public init() {}
    }
}
