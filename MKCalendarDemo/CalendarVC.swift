//
//  CalendarVC.swift
//  MKCalendarDemo
//
//  Created by Michael Lin on 1/23/21.
//

import UIKit
import MKCalendar

class CalendarVC: UIViewController {
    
    var calendar = MKCalendar(initialState: .week(date: Date()))

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.addCalendar(toParent: self)
        NSLayoutConstraint.activate([
            calendar.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            calendar.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        calendar.eventsProvider = self
        
        let redView = UIView()
        redView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(redView)
        redView.backgroundColor = .red
        NSLayoutConstraint.activate([
            redView.topAnchor.constraint(equalTo: calendar.view.bottomAnchor, constant: 20),
            redView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            redView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            redView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
}

extension CalendarVC: EventsProvider {
    func calendar(_ calendar: MKCalendar, eventsForDate date: Date) -> [EventDescriptor] {
        let now = date
        let event1 = Event(startDate: now, endDate: NSCalendar.current.date(byAdding: .hour, value: 2, to: now)!, text: "Event 1")
        event1.backgroundColor = .cyan
        let event2 = Event(startDate: NSCalendar.current.date(byAdding: .minute, value: 30, to: now)!, endDate: NSCalendar.current.date(byAdding: .hour, value: 1, to: now)!, text: "Event 2")
        event2.backgroundColor = .brown
        let event3 = Event(startDate: NSCalendar.current.date(byAdding: .hour, value: 1, to: now)!, endDate: NSCalendar.current.date(byAdding: .hour, value: 4, to: now)!, text: "Event 3")
        return [event1, event2, event3]
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
