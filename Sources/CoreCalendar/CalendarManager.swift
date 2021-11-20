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
    
    @Published private(set) var selectedDays = Set<CalendarDay>()
    
    var calendarCellReusePool = ReusePool<CalendarCell>()
    
    var allowMultipleSelection = false
    
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
