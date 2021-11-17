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
    
    // TODO: Event Indicator
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.sizeToFit()
        numberLabel.center = contentView.center
        
        let selectedBackgroundSize = min(
            bounds.width, bounds.height) - 15
        backgroundView?.frame = CGRect(
            origin: .zero,
            size: CGSize(width: selectedBackgroundSize,
                         height: selectedBackgroundSize))
        backgroundView?.center = contentView.center
        backgroundView?.layer
            .cornerRadius = selectedBackgroundSize / 2
    }
    
    func configure(using day: CalendarDay,
                   state: CalendarState) {
        let calendar = CalendarManager.calendar
        numberLabel.text = "\(calendar.component(.day, from: day.date))"
        numberLabel.font = style.font
        contentView.addSubview(numberLabel)
        
        if state.currentLayout == .month {
            let startOfMonth = state.firstDateInMonthOrWeek
            let endOfMonth = calendar.endOfMonth(
                for: startOfMonth)
            let monthRange = startOfMonth...endOfMonth
            numberLabel.textColor = monthRange.contains(
                day.date) ?
            style.textColor : style.inactiveTextColor
        } else {
            numberLabel.textColor = style.textColor
        }
        
        backgroundView = UIView()
        backgroundView?.clipsToBounds = true
        backgroundView?
            .backgroundColor = day.isToday ?
        style.todayBackgroundColor : style.selectedBackgroundColor
    }
}
