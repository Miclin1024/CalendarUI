//
//  MKCalendar.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public protocol MKCalendarDelegate: class {
    func calendar(_ calendar: MKCalendar, didSelectDate date: Date)
    func calendar(_ calendar: MKCalendar, didDeselectDates dates: [Date])
}

public class MKCalendar: UIViewController {
    
    public weak var delegate: MKCalendarDelegate?
    
    public weak var eventsProvider: EventsProvider? {
        didSet {
            updateTimelineView()
        }
    }
    
    public var calendarState: CalendarState {
        get {
            return calendarPage.calendarState
        }
    }
    
    public var selectedDays: [Day] {
        get {
            return calendarPage.selectedDays
        }
    }
    
    public var hideTimelineView: Bool = false {
        didSet{
            if case .week = calendarState.mode, !hideTimelineView {
                timelineContainerHeightConstraint.constant = layout.timelineHuggingHeight
            } else {
                timelineContainerHeightConstraint.constant = 0
            }
        }
    }
    
    public var headerView: HeaderView = HeaderView()
    
    public var timeline: TimelineView = TimelineView()
    
    public var calendarPage: CalendarPageController
    
    var layout: MKCalendarLayout = MKCalendarDefaultLayout()
    
    var style = MKCalendarStyle()
    
    var calendar = NSCalendar.current
    
    lazy var timelineContainer: TimelineContainer = {
        let container = TimelineContainer(timeline)
        container.addSubview(timeline)
        return container
    }()
    
    var calendarPageHeightConstraint: NSLayoutConstraint!
    
    var headerPaddingConstraint: NSLayoutConstraint!

    var timelineContainerHeightConstraint: NSLayoutConstraint!
    
    public init(initialState state: CalendarState) {
        calendarPage = CalendarPageController(initialState: state)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        calendarPage = CalendarPageController(initialState: CalendarState(mode: .month, date: Date()))
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        let contentPadding = layout.edgeInset(forCalendarState: calendarState)
        view.translatesAutoresizingMaskIntoConstraints = false
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
        calendarPage.handler = self
        headerPaddingConstraint = calendarPage.view.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: style.headerBottomPadding)
        NSLayoutConstraint.activate([
            headerPaddingConstraint,
            calendarPage.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentPadding.left),
            calendarPage.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentPadding.right),
        ])

        let width = view.bounds.inset(by: contentPadding).width
        let weekViewRowHeight: CGFloat = width / 7
        var calendarPageHeight: CGFloat
        if case .week = calendarState.mode {
            calendarPageHeight = weekViewRowHeight
        } else {
            calendarPageHeight = weekViewRowHeight * 6
        }
        calendarPageHeightConstraint = calendarPage.view.heightAnchor.constraint(equalToConstant: calendarPageHeight)
        calendarPageHeightConstraint.isActive = true
        
        view.addSubview(timelineContainer)
        timelineContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineContainer.topAnchor.constraint(equalTo: calendarPage.view.bottomAnchor),
            timelineContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentPadding.left),
            timelineContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentPadding.right),
            timelineContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if case .week = calendarState.mode, !hideTimelineView {
            timelineContainerHeightConstraint = timelineContainer.heightAnchor.constraint(equalToConstant: layout.timelineHuggingHeight)
        } else {
            timelineContainerHeightConstraint = timelineContainer.heightAnchor.constraint(equalToConstant: 0)
        }

        timelineContainerHeightConstraint.priority = .defaultHigh
        timelineContainerHeightConstraint.isActive = true
        
        updateHeaderView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveCalendarUpdate(_:)), name: .didUpdateCalendar, object: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineContainer.contentSize = timeline.frame.size
    }
    
    // MARK: Calendar Update
    
    open func updateStyle(_ newStyle: MKCalendarStyle) {
        style = newStyle
        
        timeline.updateStyle(style.timeline)
        headerView.updateStyle(style.header)
        calendarPage.updateStyle(style.calendar)
        
        headerPaddingConstraint.constant = style.headerBottomPadding
        view.backgroundColor = style.backgroundColor
    }
    
    open func updateLayout(_ newLayout: MKCalendarLayout) {
        layout = newLayout
        
        if case .week = calendarState.mode {
            timelineContainerHeightConstraint.constant = hideTimelineView ? 0 : layout.timelineHuggingHeight
        }
    }
    
    public func addCalendar(toParent parent: UIViewController) {
        parent.addChild(self)
        self.didMove(toParent: parent)
        parent.view.addSubview(self.view)
    }
    
    public func reloadData() {
        updateTimelineView()
    }
    
    // MARK: Calendar Subviews Update
    
    func updateHeaderView() {
        switch calendarState.mode {
        case .month:
            let month = calendarState.date
            let endOfMonth = calendar.getLastDayInMonth(fromDate: month)!
            let range = month ... endOfMonth
            let datesInCurrentMonth = selectedDays.compactMap { (day : Day) -> Date? in
                range.contains(day.date) ? day.date : nil
            }
            headerView.updateSymbolHighlight(usingDates: datesInCurrentMonth)
        case .week:
            let week = calendarState.date
            let endOfWeek = calendar.getLastDayOfWeek(fromDate: week)!
            let range = week ... endOfWeek
            let datesInCurrentWeek = selectedDays.compactMap { (day: Day) -> Date? in
                range.contains(day.date) ? day.date : nil
            }
            headerView.updateSymbolHighlight(usingDates: datesInCurrentWeek)
        }
        headerView.selectedDates = self.selectedDays.map {$0.date}
        headerView.titleLabel.text = layout.calendarTitle(self, forCalendarState: calendarState, selectedDays: selectedDays)
    }
    
    func updateTimelineView() {
        let selectedDate: Date = (selectedDays.first?.date ?? Date()).dateOnly(calendar: calendar)
        timeline.date = selectedDate
        let end = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
        let day = selectedDate ... end
        let events = eventsProvider?.calendar(self, eventsForDate: selectedDate)
        let validEvents = events?.filter{$0.datePeriod.overlaps(day)}
        timeline.layoutAttributes = validEvents?.map(EventLayoutAttributes.init) ?? []
        
    }
    
    public func setHideTimelineView(_ value: Bool, animated: Bool) {
        hideTimelineView = value
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.view.superview!.layoutIfNeeded()
                self.view.layoutIfNeeded()
                self.timelineContainer.layoutIfNeeded()
            }
        }
    }
    
    public func transition(toCalendarState state: CalendarState, animated: Bool, completion: ((Bool)->Void)?) {
        
        guard calendarState != state else {
            completion?(false)
            return
        }
        
        self.calendarPage.transition(toCalendarState: state, animated: true)
        let contentPadding = layout.edgeInset(forCalendarState: state)
        let width = view.bounds.inset(by: contentPadding).width
        let weekViewRowHeight: CGFloat = width / 7
        if case .week = state.mode {
            timelineContainerHeightConstraint.constant = hideTimelineView ? 0 : layout.timelineHuggingHeight
            calendarPageHeightConstraint.constant = weekViewRowHeight
        } else {
            timelineContainerHeightConstraint.constant = 0
            calendarPageHeightConstraint.constant = weekViewRowHeight * 6
        }
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.view.superview?.layoutIfNeeded()
                self.timelineContainer.layoutIfNeeded()
                self.calendarPage.view.layoutIfNeeded()
            }, completion: completion)
        }
    }
    
    @objc func didReceiveCalendarUpdate(_ notification: Notification) {
        updateHeaderView()
        updateTimelineView()
    }
    
    public enum DisplayMode: CaseIterable {
        case month, week
    }

    public enum SelectionMode {
        case single, multiple
    }
}

extension MKCalendar: CalendarPageEventHandler {
    func calendarPage(didSelectDay day: Day) {
        delegate?.calendar(self, didSelectDate: day.date)
    }
    
    func calendarPage(didDeselectDays days: [Day]) {
        guard days.count != 0 else { return }
        delegate?.calendar(self, didDeselectDates: days.map{ $0.date })
    }
}
