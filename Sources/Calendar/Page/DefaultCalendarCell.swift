//
//  DefaultCalendarCell.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import UIKit

class DefaultCalendarCell: CalendarCell {
    
    var day: CalendarDay!
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    func configure(using day: CalendarDay) {
        let calendar = CalendarManager.main.calendar
        numberLabel.text = "\(calendar.component(.day, from: day.date))"
        
        
    }
}
