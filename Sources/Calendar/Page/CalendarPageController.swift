//
//  CalendarPageController.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import Foundation
import UIKit

final class CalendarPageController: UIPageViewController {
    
    private var pagePool = [CalendarState.Key: Page]()
    
    var style = CalendarStyle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CalendarPageController {
//    private func page(for )
}
