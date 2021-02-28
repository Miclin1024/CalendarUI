//
//  CalendarPageController.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

protocol CalendarPageDelegate: class {
    func calendarPage(didSelectDay day: Day)
    func calendarPage(didDeselectDays days: [Day])
}

public class CalendarPageController: UIPageViewController {
    
    let calendar = NSCalendar.current
    
    weak var pageDelegate: CalendarPageDelegate?
    
    var selectedDays: [Day] = []
    
    var calendarState: CalendarState
    
    private(set) var calendarVCs: [Date: CalendarVC] = [:]
    
    private(set) var calendarViewStyle: CalendarViewStyle
    
    init(initialState: CalendarState, style: CalendarViewStyle = CalendarViewStyle()) {
        calendarState = initialState
        calendarViewStyle = style
        
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
        
        let initialView = getCalendarController(forCalendarState: calendarState)
        setViewControllers([initialView], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: Style Update
    
    func updateStyle(_ newStyle: CalendarViewStyle) {
        calendarViewStyle = newStyle
        calendarVCs.forEach { _, val in
            val.updateStyle(newStyle)
        }
    }
}

extension CalendarPageController {
    private func getCalendarController(forCalendarState state: CalendarState) -> CalendarVC {
        if let vc = calendarVCs[state.date] {
            return vc
        } else {
            let vc = CalendarVC(displayMode: state.mode, startingDate: state.date)
            configureSelection(forCalendarVC: vc)
            vc.delegate = self
            calendarVCs[state.date] = vc
            return vc
        }
    }
    
    private func configureSelection(forCalendarVC vc: CalendarVC) {
        selectedDays.forEach { day in
            if let indexPath = vc.dataSource.indexPath(for: day) {
                vc.calendarCollectionView.selectItem(at: indexPath, animated: false,
                                                     scrollPosition: .bottom)
            }
        }
    }
}

// MARK: Transition
extension CalendarPageController {
    func transition(toCalendarState state: CalendarState, animated: Bool) {
        if state.mode == self.calendarState.mode {
            let vc = getCalendarController(forCalendarState: state)
            let dir: UIPageViewController.NavigationDirection = state
                .date.compare(self.calendarState.date) != .orderedAscending ?
                .forward : .reverse
            setViewControllers([vc], direction: dir, animated: true) { [weak self] _ in
                self?.calendarState = state
                NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
            }
        } else {
            let (month, week) = state.mode == .month ?
                (state.date, self.calendarState.date) : (self.calendarState.date, state.date)
            let range = month ... calendar.date(byAdding: .month, value: 1, to: month)!
            
            guard let currentvc = viewControllers?.first as? CalendarVC else {
                fatalError("Couldn't get the currently presented calendar vc")
            }
            // Clear the view controller cache
            calendarVCs.removeAll()
            
            if range.contains(week) {
                calendarVCs[state.date] = currentvc
                setViewControllers([currentvc], direction: .forward, animated: false, completion: nil)
                currentvc.updateDisplay(state.mode, startingDate: state.date) { [weak self] in
                    self?.calendarState = state
                    NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
                }
            } else {
                let destinationvc = getCalendarController(forCalendarState: state)
                let dir: UIPageViewController.NavigationDirection = state
                    .date.compare(self.calendarState.date) != .orderedAscending ?
                    .forward : .reverse
                calendarVCs[state.date] = destinationvc
                
                // Collapse the currently presenting vc for animation
                currentvc.updateDisplay(state.mode, startingDate: self.calendarState.date)
                
                setViewControllers([destinationvc], direction: dir, animated: true) { [weak self] _ in
                    self?.calendarState = state
                    NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
                }
            }
        }
    }
}

// MARK: PageViewController DataSource

extension CalendarPageController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? CalendarVC else {
            fatalError("Couldn't create new calendar vc")
        }
        switch calendarState.mode {
        case .month:
            let date = calendar.date(byAdding: .month, value: -1, to: vc.startingDate)!
            let state = CalendarState(mode: .month, date: date)
            return getCalendarController(forCalendarState: state)
        case .week:
            let date = calendar.date(byAdding: .day, value: -7, to: vc.startingDate)!
            let state = CalendarState(mode: .week, date: date)
            return getCalendarController(forCalendarState: state)
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? CalendarVC else {
            fatalError("Couldn't create new calendar vc")
        }
        switch calendarState.mode {
        case .month:
            let date = calendar.date(byAdding: .month, value: 1, to: vc.startingDate)!
            let state = CalendarState(mode: .month, date: date)
            return getCalendarController(forCalendarState: state)
        case .week:
            let date = calendar.date(byAdding: .day, value: 7, to: vc.startingDate)!
            let state = CalendarState(mode: .week, date: date)
            return getCalendarController(forCalendarState: state)
        }
    }
}

// MARK: PageViewController Delegate
extension CalendarPageController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let _ = pendingViewControllers.first! as! CalendarVC
        
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let vc = pageViewController.viewControllers?.first as? CalendarVC else {
            fatalError("Unexpected view controller in Calendar Page Controller")
        }
        calendarState = CalendarState(mode: vc.displayMode, date: vc.startingDate)
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
    }
}

// MARK: CalendarVC Delegate
extension CalendarPageController: CalendarVCDelegate {
    public func calendarVC(_ calendarVC: CalendarVC, didSelectDay day: Day) {
        var deselectedDays: [Day] = []
        if selectedDays.count != 0 && !calendarViewStyle.allowMultipleSelection {
            selectedDays.forEach { day in
                self.deselectCell(withDay: day)
                deselectedDays.append(day)
            }
            selectedDays.removeAll()
        }
        selectedDays.append(day)
        
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
        pageDelegate?.calendarPage(didDeselectDays: [day])
        pageDelegate?.calendarPage(didSelectDay: day)
    }
    
    public func calendarVC(_ calendarVC: CalendarVC, didDeselectDay day: Day) {
        selectedDays.removeAll(where: {day == $0})
        self.deselectCell(withDay: day)
        
        NotificationCenter.default.post(name: .didUpdateCalendar, object: nil)
        pageDelegate?.calendarPage(didDeselectDays: [day])
    }
    
    private func deselectCell(withDay day: Day) {
        var vc: CalendarVC! = nil
        switch calendarState.mode {
        case .week:
            let week = calendar.getFirstDayOfWeek(fromDate: day.date)!
            vc = calendarVCs[week]
        case .month:
            let month = calendar.getMonth(fromDate: day.date)!
            vc = calendarVCs[month]
        }
        guard vc != nil else { return }
        guard let indexPath = vc.dataSource.indexPath(for: day) else { return }
        vc.calendarCollectionView.deselectItem(at: indexPath, animated: true)
    }
}
