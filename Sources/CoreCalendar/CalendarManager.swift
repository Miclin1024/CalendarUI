//
//  CalendarManager.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Combine

final class CalendarManager {
    
    static let main = CalendarManager()
    
    static var calendar = Calendar.current
    
    weak var calendarDataSource: CalendarUIDataSource?
    
    @Published var state = CalendarState(
        withLayout: .month, date: .now)
    
    @Published var isTimelineEnabled: Bool = false
    
    @Published var selectedDates = Set<CalendarDay>()
    
    var calendarCellReusePool = ReusePool<CalendarCell>()
}
