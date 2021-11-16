//
//  CalendarManager.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation

final class CalendarManager {
    
    static let main = CalendarManager()
    
    var calendar = Calendar.current
    
    weak var calendarDataSource: CalendarUIDataSource?
    
    var statePool = [CalendarState.Key: CalendarState]()
    
    lazy var state = CalendarState.state(withLayout: .month, date: .now)
    
    var calendarCellReusePool = ReusePool<CalendarCell>()
    
    var selectedDates = [Date]()
}
