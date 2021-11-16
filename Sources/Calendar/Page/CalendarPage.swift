//
//  CalendarPage.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation
import UIKit

extension CalendarPageController {
    final class Page: UIViewController {
        
        var state: CalendarState
        
        var calendarCollection: CalendarCollectionView!
        
        init(state: CalendarState) {
            self.state = state
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
    }
}

extension CalendarPageController.Page {
    
}
