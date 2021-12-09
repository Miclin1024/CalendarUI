//
//  WeeklyWithSingleSelection.swift
//  CalendarUISampleApp
//
//  Created by Michael Lin on 11/29/21.
//

import UIKit
import CalendarUI

class WeeklyWithSingleSelection: UIViewController {
    
    var calendar: CalendarUI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        var configuration = CalendarUI.Configuration()
        configuration.calendarConfiguration.allowMultipleSelection = false
        
        calendar = CalendarUI(
            initialState: .init(withLayout: .week, date: .now),
            configuration: configuration)
        addChild(calendar)
        calendar.didMove(toParent: self)
        view.addSubview(calendar.view)
    }
    
    override func viewDidLayoutSubviews() {
        calendar.view.frame = view.bounds
            .inset(by: view.safeAreaInsets)
            .inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
}
