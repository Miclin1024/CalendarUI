//
//  WeekMonthTransitions.swift
//  CalendarUISampleApp
//
//  Created by Michael Lin on 11/30/21.
//

import UIKit
import CalendarUI

class WeekMonthTransitions: UIViewController {
    
    var calendar: CalendarUI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        var configuration = CalendarUI.Configuration()
        configuration.calendarConfiguration.allowMultipleSelection = true
        
        calendar = CalendarUI(configuration: configuration)
        addChild(calendar)
        calendar.didMove(toParent: self)
        calendar.view
            .translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendar.view)
        
        var buttonConfig = UIButton.Configuration.tinted()
        buttonConfig.title = "Switch Layout"
        let button = UIButton(
            configuration: buttonConfig,
            primaryAction: UIAction() { action in
                let state = self.calendar.currentState
                let newState = CalendarState(
                    withLayout: state.layout == .week ?
                        .month : .week,
                    date: .now)
                self.calendar.transition(to: newState, animated: true)
            })
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            calendar.view.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            calendar.view.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20),
            calendar.view.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            calendar.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            button.topAnchor.constraint(
                equalTo: calendar.view.bottomAnchor,
                constant: 20),
            button.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
        ])
    }
}
