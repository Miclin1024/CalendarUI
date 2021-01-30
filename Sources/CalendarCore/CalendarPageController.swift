//
//  CalendarPageController.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

protocol CalendarPageEventHandler: class {
    func calendarPage(didSelectDay day: Day)
    func calendarPage(didDeselectDays days: [Day])
}

public class CalendarPageController: UIPageViewController {
    
    let calendar = NSCalendar.current
    
    weak var handler: CalendarPageEventHandler?
    
    var selectedDays: [Day] = []
    
    var calendarState: CalendarState
    
    var transitionDuration: CFTimeInterval = 0.5
    
    private(set) var monthViews: [Date: MonthView<DayCell>] = [:]
    
    var monthViewStyle: MonthViewStyle = MonthViewStyle()
    
    private(set) var weekViews: [Date: WeekView<DayCell>] = [:]
    
    var weekViewStyle: WeekViewStyle = WeekViewStyle()
    
    init(initialState: CalendarState) {
        calendarState = initialState
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        dataSource = self
        delegate = self
        
        let initialView = getViewController(fromCalendarState: self.calendarState)
        setViewControllers([initialView], direction: .forward, animated: false, completion: nil)
    }
    
    private func getViewController(fromCalendarState state: CalendarState) -> UIViewController {
        var vc: UIViewController
        switch state.mode {
        case .month:
            vc = getMonthView(forDate: state.date)
        case .week:
            vc = getWeekView(forDate: state.date)
        }
        return vc
    }
    
    // MARK: Week/Month View Factory
    
    private func getMonthView(forDate date: Date) -> MonthView<DayCell> {
        let month = calendar.getMonth(fromDate: date)!
        if let monthView = monthViews[month] {
            return monthView
        } else {
            let monthView = MonthView(date: month)
            monthView.delegate = self
            monthView.updateStyle(monthViewStyle)
            monthViews[month] = monthView
            return monthView
        }
    }
    
    private func getWeekView(forDate date: Date) -> WeekView<DayCell> {
        let week = calendar.getFirstDayOfWeek(fromDate: date)!
        if let weekView = weekViews[week] {
            return weekView
        } else {
            let weekView = WeekView(date: week)
            weekView.delegate = self
            weekView.updateStyle(weekViewStyle)
            weekViews[week] = weekView
            return weekView
        }
    }
    
    // MARK: Transition
    
    func transition(toCalendarState state: CalendarState, animated: Bool) {
        let vc = getViewController(fromCalendarState: state)
        let dir: UIPageViewController.NavigationDirection = state.date.compare(self.calendarState.date) != .orderedAscending ? .forward : .reverse
        switch state.mode {
        case .month:
            let monthView = vc as! MonthView
            for item in 0 ..<
                monthView.collectionView.numberOfItems(inSection: 0) {
                let ip = IndexPath(item: item, section: 0)
                if selectedDays.contains(monthView.days[ip.item]) {
                    monthView.collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
                }
            }
        case .week:
            let weekView = vc as! WeekView
            for item in 0 ..<
                weekView.collectionView.numberOfItems(inSection: 0) {
                let ip = IndexPath(item: item, section: 0)
                if selectedDays.contains(weekView.days[ip.item]) {
                    weekView.collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
                }
            }
        }
        
        self.setViewControllers([vc], direction: dir, animated: true, completion: { [weak self] _ in
            self!.calendarState = state
            NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
        })
    }
    
    // MARK: Style Update
    
    func updateStyle(month monthViewStyle: MonthViewStyle, week weekViewStyle: WeekViewStyle) {
        self.monthViewStyle = monthViewStyle
        self.weekViewStyle = weekViewStyle
        
        monthViews.forEach { key, val in
            val.updateStyle(monthViewStyle)
        }
        
        weekViews.forEach { key, val in
            val.updateStyle(weekViewStyle)
        }
    }
}

// MARK: PageViewController Data Source

extension CalendarPageController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch calendarState.mode {
        case .month:
            let vc = viewController as! MonthView
            let date = calendar.date(byAdding: .month, value: -1, to: vc.month)!
            return getMonthView(forDate: date)
        case .week:
            let vc = viewController as! WeekView
            let date = calendar.date(byAdding: .day, value: -7, to: vc.week)!
            return getWeekView(forDate: date)
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch calendarState.mode {
        case .month:
            let vc = viewController as! MonthView
            let date = calendar.date(byAdding: .month, value: 1, to: vc.month)!
            return getMonthView(forDate: date)
        case .week:
            let vc = viewController as! WeekView
            let date = calendar.date(byAdding: .day, value: 7, to: vc.week)!
            return getWeekView(forDate: date)
        }
    }
}

// MARK: PageViewController Delegate

extension CalendarPageController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first! as? MonthView {
            for item in 0 ..<
                vc.collectionView.numberOfItems(inSection: 0) {
                let ip = IndexPath(item: item, section: 0)
                if selectedDays.contains(vc.days[ip.item]) {
                    vc.collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
                }
            }
        } else if let vc = pendingViewControllers.first! as? WeekView {
            for item in 0 ..<
                vc.collectionView.numberOfItems(inSection: 0) {
                let ip = IndexPath(item: item, section: 0)
                if selectedDays.contains(vc.days[ip.item]) {
                    vc.collectionView.selectItem(at: ip, animated: false, scrollPosition: [])
                }
            }
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let monthView = self.viewControllers?.first as? MonthView {
            calendarState = CalendarState(mode: .month, date: monthView.month)
        } else if let weekView = self.viewControllers?.first as? WeekView {
            calendarState = CalendarState(mode: .week, date: weekView.week)
        }
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
    }
}

extension CalendarPageController: MonthViewDelegate, WeekViewDelegate {
    public func monthView(_ monthView: MonthView<DayCell>, willSelectDay day: Day, at indexPath: IndexPath) {
        var deselectedDays: [Day] = []
        if selectedDays.count != 0 && !monthView.style.allowMultipleSelection {
            selectedDays.forEach { day in
                self.deselectCells(withDay: day)
                deselectedDays.append(day)
            }
            selectedDays.removeAll()
        }
        selectedDays.append(day)
        self.selectCellInWeekViews(withDay: day, animated: false)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
        if selectedDays.count != 0 {
            handler?.calendarPage(didDeselectDays: deselectedDays)
        }
        handler?.calendarPage(didSelectDay: day)
    }
    
    public func monthView(_ monthView: MonthView<DayCell>, willDeselectDay day: Day, at indexPath: IndexPath) {
        selectedDays.removeAll(where: {day == $0})
        self.deselectCells(withDay: day)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
        handler?.calendarPage(didDeselectDays: [day])
    }
    
    public func weekView(_ weekView: WeekView<DayCell>, willSelectDay day: Day, at indexPath: IndexPath) {
        var deselectedDays: [Day] = []
        if selectedDays.count != 0 {
            selectedDays.forEach { day in
                self.deselectCells(withDay: day)
                deselectedDays.append(day)
            }
            selectedDays.removeAll()
        }
        selectedDays.append(day)
        self.selectCellInMonthViews(withDay: day, animated: false)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
        if deselectedDays.count != 0 {
            handler?.calendarPage(didDeselectDays: deselectedDays)
        }
        handler?.calendarPage(didSelectDay: day)
    }
    
    public func weekView(_ weekView: WeekView<DayCell>, willDeselectDay day: Day, at indexPath: IndexPath) {
        selectedDays.removeAll(where: {day == $0})
        self.deselectCells(withDay: day)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
        handler?.calendarPage(didDeselectDays: [day])
    }
    
    func selectCellInWeekViews(withDay day: Day, animated: Bool) {
        let week = calendar.getFirstDayOfWeek(fromDate: day.date)!
        if let weekView = weekViews[week] {
            weekView.collectionView.indexPathsForVisibleItems.forEach { indexPath in
                let cell = weekView.collectionView.cellForItem(at: indexPath) as! DayCell
                if cell.day == day && !cell.isSelected {
                    weekView.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
                }
            }
        }
    }
    
    func selectCellInMonthViews(withDay day: Day, animated: Bool) {
        let month = calendar.getMonth(fromDate: day.date)!
        if let monthView = monthViews[month] {
            monthView.collectionView.indexPathsForVisibleItems.forEach { indexPath in
                let cell = monthView.collectionView.cellForItem(at: indexPath) as! DayCell
                if cell.day == day && !cell.isSelected {
                    monthView.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
                }
            }
        }
    }
    
    func deselectCells(withDay day: Day) {
        let month = calendar.getMonth(fromDate: day.date)!
        if let monthView = monthViews[month] {
            monthView.collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                let cell = monthView.collectionView.cellForItem(at: indexPath) as! DayCell
                if cell.day == day {
                    monthView.collectionView.deselectItem(at: indexPath, animated: true)
                }
            }
        }
        
        let week = calendar.getFirstDayOfWeek(fromDate: day.date)!
        if let weekView = weekViews[week] {
            weekView.collectionView.indexPathsForSelectedItems?.forEach {
                indexPath in
                let cell = weekView.collectionView.cellForItem(at: indexPath) as! DayCell
                if cell.day == day {
                    weekView.collectionView.deselectItem(at: indexPath, animated: true)
                }
            }
        }
    }
}


