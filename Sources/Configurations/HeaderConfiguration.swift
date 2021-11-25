//
//  HeaderConfiguration.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import UIKit

/**
 Weekday symbol style used in `HeaderView`.
 */
public enum WeekdaySymbolStyle: Equatable {
    /** Standalone weekday names. */
    case regular
    
    /** Shorter-named standalone weekdays. */
    case short
    
    /** Very-shortly-named standalone weekdays. */
    case veryShort
    
    case custom(symbols: [String])
    
    /**
     The list of symbols associated with the style.
     */
    var symbols: [String] {
        let calendar = CalendarManager.calendar
        switch self {
        case .regular:
            return calendar.standaloneWeekdaySymbols
        case .short:
            return calendar.shortStandaloneWeekdaySymbols
        case .veryShort:
            return calendar.veryShortStandaloneWeekdaySymbols
        case .custom(let symbols):
            assert(symbols.count == 7,
                   "Invalid custom weekday symbols")
            return symbols
        }
    }
}

public extension CalendarUI.Configuration {
    
    /**
     Configuration object for the calendar's header view.
     */
    struct HeaderConfiguration: Equatable {        
        
        public var symbolStyle: WeekdaySymbolStyle = .veryShort
        
        /** Font for the symbol labels. */
        public var symbolFont = UIFont.systemFont(
            ofSize: 12, weight: .semibold)
        
        /** The base color for the symbol labels. */
        public var symbolColor = UIColor.secondaryLabel
        
        /** The padding between title and symbol row. */
        public var spacing: CGFloat = 15.0
        
        /** Font for the header title. */
        public var titleFont = UIFont.systemFont(
            ofSize: 15, weight: .bold)
        
        /** Color for the header title. */
        public var titleColor = UIColor.label
        
        /** Enable the highlighting of appropriate weekday symbols.  */
        public var highlightSelected = true
        
        /** Accent color for highlighting appropriate weekday symbols. */
        public var accentColor = UIColor.systemBlue
        
        public init() {}
    }
}
