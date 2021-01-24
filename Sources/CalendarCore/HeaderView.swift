//
//  HeaderView.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

class HeaderView: UIView {
    
    let calendar = NSCalendar.current
    
    open var transitionDuration: CFTimeInterval = 0.5
    
    var style: HeaderStyle = HeaderStyle()
    
    var selectedDates: [Date] = []
    
    private var weekdaySymbols: [String] {
        get {
            switch style.symbolType {
            case .normal:
                return calendar.standaloneWeekdaySymbols
            case .short:
                return calendar.shortStandaloneWeekdaySymbols
            case .veryshort:
                return calendar.veryShortStandaloneWeekdaySymbols
            case .custom(value: let value):
                guard value.count == 7 else {
                    fatalError("Invalid value for custom weekday symbol: must have exactly 7 elements!")
                }
                return value
            }
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    var weekdaySymbolLabels: [UILabel] = []
    
    var titleSpacingConstraint: NSLayoutConstraint!
    
    private var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    convenience init() {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = style.titleColor
        titleLabel.font = style.titleFont
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        weekdaySymbolLabels = weekdaySymbols.map { str -> UILabel in
            let label = UILabel()
            label.textColor = style.labelColor
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.text = str
            label.textAlignment = .center
            return label
        }
        
        addSubview(stackView)
        titleSpacingConstraint = stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: style.titleBottomPadding)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleSpacingConstraint,
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        weekdaySymbolLabels.forEach { self.stackView.addArrangedSubview($0) }
    }
    
    func updateStyle(_ newStyle: HeaderStyle) {
        style = newStyle
        titleSpacingConstraint.constant = style.titleBottomPadding
        updateSymbolHighlight(usingDates: selectedDates)
        titleLabel.textColor = style.titleColor
        titleLabel.font = style.titleFont
    }
    
    func updateSymbolHighlight(usingDates dates: [Date]) {
        let selectedSymbolIndices = Set(dates.map {
            calendar.component(.weekday, from: $0) - 1
        })
        CATransaction.begin()
        CATransaction.setAnimationDuration(transitionDuration)
        weekdaySymbolLabels.enumerated().forEach { index, elem in
            if selectedSymbolIndices.contains(index) {
                elem.textColor = style.accentColor
            } else {
                elem.textColor = style.labelColor
            }
        }
        CATransaction.commit()
    }
    
    private func updateStyle() {
        
    }
}
