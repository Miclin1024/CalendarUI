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
    
    static func initialize(withState state: CalendarState? = nil) {
        if let state = state {
            main = CalendarManager(state: state)
        } else {
            main = CalendarManager()
        }
    }
    
    weak var calendarDataSource: CalendarUIDataSource?
    
    @Published var state: CalendarState
    
    @Published var isTimelineEnabled: Bool = false
    
    @Published private(set) var selectedDays = Set<CalendarDay>()
    
    private var calendarCellReusePools = [ObjectIdentifier: ReusePool<CalendarCell>]()
    
    var allowMultipleSelection = false
    
    init(state: CalendarState = CalendarState(
        withLayout: .month, date: .now)) {
        self.state = state
    }
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

// MARK: Reuse Pool
extension CalendarManager {
    
    func fetchReusePool<Cell: CalendarCell>(for cellType: Cell.Type) -> ReusePool<Cell> {
        let identifier = ObjectIdentifier(cellType)
        guard let pool = calendarCellReusePools[identifier] else {
            calendarCellReusePools[identifier] = ReusePool<CalendarCell>()
            return ReusePool<Cell>()
        }
        
        guard let poolCasted = pool as? ReusePool<Cell> else {
            fatalError("Unexpected type found in cell reuse pool")
        }
        
        return poolCasted
    }
}
