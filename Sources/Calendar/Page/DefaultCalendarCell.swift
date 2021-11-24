//
//  DefaultCalendarCell.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import UIKit

class DefaultCalendarCell: CalendarCell {
    
    var day: CalendarDay!
    
    var state: CalendarState!
    
    override var isSelected: Bool {
        didSet {
            animateSelection()
        }
    }
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let calendar = CalendarManager.calendar
    
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
}

// MARK: View Configuration
extension DefaultCalendarCell {
    func configure(using day: CalendarDay,
                   state: CalendarState) {
        self.day = day
        self.state = state
        let date = day.date
        
        let calendar = CalendarManager.calendar
        numberLabel.text = "\(calendar.component(.day, from: date))"
        numberLabel.font = configuration.font
        contentView.addSubview(numberLabel)
        
        numberLabel.textColor = numberLabelTextColor()
        
        backgroundView = UIView()
        backgroundView?.clipsToBounds = true
        
        if day.isToday {
            backgroundView?.backgroundColor = configuration.todayBackgroundColor
            numberLabel.textColor = configuration.todayTextColor
        } else {
            backgroundView?.backgroundColor = configuration.selectedBackgroundColor
            backgroundView?.alpha = isSelected ? 1 : 0
        }
    }
    
    /**
     Returns the color based on selection status, the underlying calendar day and state.
     */
    func numberLabelTextColor() -> UIColor {
        // If the selected cell is also today, use a lighter version of
        // selection background for the number text
        // FIXME: This looks kinda ugly with the default style
        if isSelected && day.isToday { return configuration
            .selectedBackgroundColor.withAlphaComponent(0.5)}
        
        if isSelected { return configuration.selectedTextColor }
        if day.isToday { return configuration.todayTextColor }
        switch state.layout {
        case .week:
            return calendar.isDateInWeekend(day.date) ?
            configuration.inactiveTextColor : configuration.textColor
        case .month:
            let startOfMonth = state.firstDateInMonthOrWeek
            let endOfMonth = calendar.endOfMonth(
                for: startOfMonth)
            let monthRange = startOfMonth...endOfMonth
            return monthRange.contains(day.date) ?
            configuration.textColor : configuration.inactiveTextColor
        }
    }
}

// MARK: Animations
private extension DefaultCalendarCell {
    func animateSelection() {
        numberLabel.textColor = numberLabelTextColor()
        
        // No need to fade out if the selection is today
        if day.isToday { return }
        
        UIView.animate(withDuration: 0.2) {
            self.backgroundView?.alpha = self.isSelected ? 1 : 0
        }
    }
}
