//
//  CalendarVC.swift
//  MKCalendarDemo
//
//  Created by Michael Lin on 1/23/21.
//

import UIKit
import MKCalendar

class CalendarVC: UIViewController {
    
    var calendar = MKCalendar(initialState: CalendarState.MonthViewToday())

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.addCalendar(toParent: self)
        NSLayoutConstraint.activate([
            calendar.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            calendar.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        calendar.eventsProvider = self
        calendar.delegate = self
    }
    
    @IBAction func toWeek(_ sender: Any) {
        if let day = calendar.selectedDays.first {
            let state = CalendarState(mode: .week, date: day.date)
            calendar.transition(toCalendarState: state, animated: true, completion: nil)
        } else {
            let state = CalendarState.WeekViewToday()
            calendar.transition(toCalendarState: state, animated: true, completion: nil)
        }
    }
    
    @IBAction func toMonth(_ sender: Any) {
        if let day = calendar.selectedDays.first {
            let state = CalendarState(mode: .month, date: day.date)
            calendar.transition(toCalendarState: state, animated: true, completion: nil)
        } else {
            let state = CalendarState.MonthViewToday()
            calendar.transition(toCalendarState: state, animated: true, completion: nil)
        }
    }
    
    @IBAction func toggleTimeline(_ sender: Any) {
        calendar.setHideTimelineView(!calendar.hideTimelineView, animated: true)
    }
}

extension CalendarVC: EventsProvider {
    func calendar(_ calendar: MKCalendar, eventsForDate date: Date) -> [EventDescriptor] {
        let now = Date()
        let event1 = Event(startDate: now, endDate: NSCalendar.current.date(byAdding: .hour, value: 2, to: now)!, text: "Event 1")
        event1.backgroundColor = .cyan
        let event2 = Event(startDate: NSCalendar.current.date(byAdding: .minute, value: 30, to: now)!, endDate: NSCalendar.current.date(byAdding: .hour, value: 1, to: now)!, text: "Event 2")
        event2.backgroundColor = .brown
        let event3 = Event(startDate: NSCalendar.current.date(byAdding: .hour, value: 1, to: now)!, endDate: NSCalendar.current.date(byAdding: .hour, value: 4, to: now)!, text: "Event 3")
        return [event1, event2, event3]
    }
}

extension CalendarVC: MKCalendarDelegate {
    func calendar(_ calendar: MKCalendar, didSelectDate date: Date) {
        print("Selected date \(date)")
    }
    
    func calendar(_ calendar: MKCalendar, didDeselectDates dates: [Date]) {
        print("Deselected dates \(dates)")
    }
    


    
}

class Event: EventDescriptor {
    var startDate: Date
    
    var endDate: Date
    
    var isAllDay: Bool = false
    
    var text: String
    
    var attributedText: NSAttributedString?
    
    var lineBreakMode: NSLineBreakMode?
    
    var font: UIFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
    
    var color: UIColor = UIColor.black.withAlphaComponent(0.2)
    
    var textColor: UIColor = .white
    
    var backgroundColor: UIColor = .systemRed
    
    var editedEvent: EventDescriptor?
    
    func makeEditable() -> Self {
        return self
    }
    
    func commitEditing() {
        
    }
    
    init(startDate: Date, endDate: Date, text: String) {
        self.startDate = startDate
        self.endDate = endDate
        self.text = text
    }
}
