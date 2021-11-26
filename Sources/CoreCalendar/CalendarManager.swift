//
//  CalendarManager.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Combine

final class CalendarManager {
    
    static var main = CalendarManager()
    
    static var calendar = Calendar.current
    
    static func initialize() {
        main = CalendarManager()
    }
    
    weak var calendarDataSource: CalendarUIDataSource?
    
    @Published var state = CalendarState(
        withLayout: .month, date: .now)
    
    @Published var isTimelineEnabled: Bool = false
    
    @Published private(set) var selectedDays = Set<CalendarDay>()
    
    var calendarCellReusePool = ReusePool<CalendarCell>()
    
    var allowMultipleSelection = false
}

// MARK: User Selection Handler
extension CalendarManager {
    
    func handleUserSelectDay(_ day: CalendarDay) {
        if allowMultipleSelection {
            selectedDays.update(with: day)
        } else {
            selectedDays.removeAll()
            selectedDays.update(with: day)
        }
    }
    
    func handleUserDeselectDay(_ day: CalendarDay) -> Bool {
        return selectedDays.remove(day) != nil
    }
}
