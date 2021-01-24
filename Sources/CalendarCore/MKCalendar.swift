//
//  MKCalendar.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

open class MKCalendar: UIViewController {
    
    open weak var delegate: MKCalendarDelegate?
    
    open weak var eventsProvider: EventsProvider?
    
    open var layout: MKCalendarLayout = MKCalendarDefaultLayout()
    
    public var displayStatus: DisplayStatus {
        get {
            return calendarPage.displayStatus
        }
    }
    
    public var selectedDays: [Day] {
        get {
            return calendarPage.selectedDays
        }
    }
    
    public var hideTimelineView: Bool = false {
        didSet{
            timelineContainerHeightConstraint.isActive = hideTimelineView
        }
    }
    
    var style: MKCalendarStyle = MKCalendarStyle()
    
    var calendar = NSCalendar.current
    
    var headerView: HeaderView = HeaderView()
    
    var timeline: TimelineView = TimelineView()
    
    lazy var timelineContainer: TimelineContainer = {
        let container = TimelineContainer(timeline)
        container.addSubview(timeline)
        return container
    }()
    
    var calendarPage = MKCalendarPageVC(initialStatus: .month(date: Date()))
    
    var calendarPageHeightConstraint: NSLayoutConstraint!
    
    var headerPaddingConstraint: NSLayoutConstraint!

    var timelineContainerHeightConstraint: NSLayoutConstraint!
    
    open override func viewDidLoad() {
        let contentPadding = layout.edgeInset(forCalendarDisplayStatus: .month(date: Date()))
        view.backgroundColor = style.backgroundColor
        
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentPadding.left),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentPadding.right),
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: contentPadding.top)
        ])
        
        addChild(calendarPage)
        calendarPage.didMove(toParent: self)
        view.addSubview(calendarPage.view)
        headerPaddingConstraint = calendarPage.view.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: style.headerBottomPadding)
        NSLayoutConstraint.activate([
            headerPaddingConstraint,
            calendarPage.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentPadding.left),
            calendarPage.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentPadding.right),
        ])
        
        let width = view.bounds.inset(by: contentPadding).width
        let weekViewRowHeight: CGFloat = width / 7
        calendarPageHeightConstraint = calendarPage.view.heightAnchor.constraint(equalToConstant: weekViewRowHeight)
        calendarPageHeightConstraint.priority = .defaultLow
        if case .week(_) = displayStatus {
            calendarPageHeightConstraint.isActive = true
        }
        
        view.addSubview(timelineContainer)
        timelineContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineContainer.topAnchor.constraint(equalTo: calendarPage.view.bottomAnchor, constant: 10),
            timelineContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentPadding.left + 10),
            timelineContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentPadding.right - 10),
            timelineContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        timelineContainerHeightConstraint = timelineContainer.heightAnchor.constraint(equalToConstant: 0)
        if case .week(_) = displayStatus {
            timelineContainerHeightConstraint.isActive = hideTimelineView
        } else {
            timelineContainerHeightConstraint.isActive = true
        }
        
        updateHeaderView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveCalendarUpdate(_:)), name: .didUpdateCalendar, object: nil)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineContainer.contentSize = timeline.frame.size
    }
    
    // MARK: Style Update
    
    public func updateStyle(_ newStyle: MKCalendarStyle) {
        style = newStyle
        
        timeline.updateStyle(style.timeline)
        headerView.updateStyle(style.header)
        calendarPage.updateStyle(month: style.month, week: style.week)
        
        headerPaddingConstraint.constant = style.headerBottomPadding
        view.backgroundColor = style.backgroundColor
    }
    
    func updateHeaderView() {
        switch displayStatus {
        case .month(let month):
            let endOfMonth = calendar.getLastDayInMonth(fromDate: month)!
            let range = month ... endOfMonth
            let datesInCurrentMonth = selectedDays.compactMap { (day : Day) -> Date? in
                range.contains(day.date) ? day.date : nil
            }
            headerView.updateSymbolHighlight(usingDates: datesInCurrentMonth)
        case .week(let week):
            let endOfWeek = calendar.getLastDayOfWeek(fromDate: week)!
            let range = week ... endOfWeek
            let datesInCurrentWeek = selectedDays.compactMap { (day: Day) -> Date? in
                range.contains(day.date) ? day.date : nil
            }
            headerView.updateSymbolHighlight(usingDates: datesInCurrentWeek)
        }
        headerView.selectedDates = self.selectedDays.map {$0.date}
        headerView.titleLabel.text = layout.calendarTitle(self, forDisplauyStatus: self.displayStatus, selectedDays: self.selectedDays)
    }
    
    func updateTimelineView() {
        
        let selectedDate: Date = (selectedDays.first?.date ?? Date()).dateOnly(calendar: calendar)
        let end = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
        let day = selectedDate ... end
        let events = eventsProvider?.calendar(self, eventsForDate: selectedDate)
        let validEvents = events?.filter{$0.datePeriod.overlaps(day)}
        timeline.layoutAttributes = validEvents?.map(EventLayoutAttributes.init) ?? []
        
    }
    
    func transition(toDisplayStatus status: DisplayStatus, animated: Bool) {
        calendarPage.transition(toDisplayStatus: status, animated: animated)
        if case .week(_) = status {
            calendarPageHeightConstraint.isActive = true
            timelineContainerHeightConstraint.isActive = hideTimelineView
        } else {
            calendarPageHeightConstraint.isActive = false
            timelineContainerHeightConstraint.isActive = true
        }
    }
    
    @objc func didReceiveCalendarUpdate(_ notification: Notification) {
        updateHeaderView()
        updateTimelineView()
    }
    
    public enum DisplayStatus {
        case month(date: Date)
        case week(date: Date)
        
        func value() -> Date {
            switch self {
            case .month(let date):
                return date
            case .week(let date):
                return date
            }
        }
    }
}

public protocol MKCalendarDelegate: class {
    func calendar(_ calendar: MKCalendar, willSelectDate: Date)
    func calendar(_ calendar: MKCalendar, willDeselectDates: [Date])
}

enum SelectionMode {
    case single, multiple
}
