//
//  CalendarPageController.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

class MKCalendarPageVC: UIPageViewController {
    
    let calendar = NSCalendar.current
    
    var selectedDays: [Day] = []
    
    var displayStatus: MKCalendar.DisplayStatus
    
    private(set) var monthViews: [Date: MonthView<DayCell>] = [:]
    
    var monthViewStyle: MonthViewStyle = MonthViewStyle()
    
    private(set) var weekViews: [Date: WeekView<DayCell>] = [:]
    
    var weekViewStyle: WeekViewStyle = WeekViewStyle()
    
    init(initialStatus: MKCalendar.DisplayStatus) {
        displayStatus = initialStatus
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        dataSource = self
        delegate = self
        
        let initialView = getViewController(fromDisplayStatus: self.displayStatus)
        setViewControllers([initialView], direction: .forward, animated: false, completion: nil)
    }
    
    private func getViewController(fromDisplayStatus status: MKCalendar.DisplayStatus) -> UIViewController {
        var vc: UIViewController
        switch status {
        case .month(let month):
            vc = getMonthView(forDate: month)
        case .week(let week):
            vc = getWeekView(forDate: week)
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
            let endOfMonth = calendar.getLastDayInMonth(fromDate: date)!
            let range = month ... endOfMonth
            let daysSelectedInCurrentMonth = selectedDays.filter { range.contains($0.date) }
            monthView.collectionView.indexPathsForVisibleItems.forEach { indexPath in
                let cell = monthView.collectionView.cellForItem(at: indexPath) as! DayCell
                if daysSelectedInCurrentMonth.contains(cell.day) {
                    monthView.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                   }
            }
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
            let endOfWeek = calendar.getLastDayOfWeek(fromDate: week)!
            let range = week ... endOfWeek
            let daysSelectedInCurrentWeek = selectedDays.filter{range.contains($0.date)}
            weekView.collectionView.indexPathsForVisibleItems.forEach { indexPath in
                let cell = weekView.collectionView.cellForItem(at: indexPath) as! DayCell
                if daysSelectedInCurrentWeek.contains(cell.day) {
                    weekView.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                }
            }
            weekView.updateStyle(weekViewStyle)
            weekViews[week] = weekView
            return weekView
        }
    }
    
    // MARK: Transition
    
    func transition(toDisplayStatus status: MKCalendar.DisplayStatus, animated: Bool) {
        let vc = getViewController(fromDisplayStatus: status)
        let dir: UIPageViewController.NavigationDirection = status.value().compare(self.displayStatus.value()) != .orderedAscending ? .forward : .reverse
        self.setViewControllers([vc], direction: dir, animated: true, completion: { [weak self] _ in
            self?.displayStatus = status
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

extension MKCalendarPageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch displayStatus {
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
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch displayStatus {
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

extension MKCalendarPageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let monthView = self.viewControllers?.first as? MonthView {
            displayStatus = .month(date: monthView.month)
        } else if let weekView = self.viewControllers?.first as? WeekView {
            displayStatus = .week(date: weekView.week)
        }
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
    }
}

extension MKCalendarPageVC: MonthViewDelegate, WeekViewDelegate {
    func monthView(_ monthView: MonthView<DayCell>, willSelectDay day: Day, at indexPath: IndexPath) {
        if selectedDays.count != 0 && !monthView.style.allowMultipleSelection {
            selectedDays.forEach { day in
                self.deselectCells(withDay: day)
            }
            selectedDays.removeAll()
        }
        selectedDays.append(day)
        self.selectCellInWeekViews(withDay: day, animated: false)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
    }
    
    func monthView(_ monthView: MonthView<DayCell>, willDeselectDay day: Day, at indexPath: IndexPath) {
        selectedDays.removeAll(where: {day == $0})
        self.deselectCells(withDay: day)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
    }
    
    func weekView(_ weekView: WeekView<DayCell>, willSelectDay day: Day, at indexPath: IndexPath) {
        if selectedDays.count != 0 {
            selectedDays.forEach { day in
                self.deselectCells(withDay: day)
            }
            selectedDays.removeAll()
        }
        selectedDays.append(day)
        self.selectCellInMonthViews(withDay: day, animated: false)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
    }
    
    func weekView(_ weekView: WeekView<DayCell>, willDeselectDay day: Day, at indexPath: IndexPath) {
        selectedDays.removeAll(where: {day == $0})
        self.deselectCells(withDay: day)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
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


