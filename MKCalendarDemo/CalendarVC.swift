//
//  CalendarVC.swift
//  MKCalendarDemo
//
//  Created by Michael Lin on 1/23/21.
//

import UIKit
import MKCalendar

class CalendarVC: UIViewController {
    
    var calendar = MKCalendar(initialState: .month(date: Date()))

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.addCalendar(toParent: self)
        NSLayoutConstraint.activate([
            calendar.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            calendar.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [self] in
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(0.5)
//
//           self.view.layoutIfNeeded()
//            CATransaction.commit()
            
            let date = Date()
            let prevMonth = NSCalendar.current.date(byAdding: .month, value: -1, to: date)!
            self.calendar.transition(toDisplayState: .week(date: prevMonth), animated: true)
        })
    }


}

