//
//  DayCell.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public class DayCell: UICollectionViewCell {
    
    public override var isSelected: Bool {
        didSet {
            updateStyle(style)
        }
    }
    
    var style: DayCellStyle = DayCellStyle()
    
    var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = view.bounds.width / 2
        return view
    }()
    
    var day: Day! {
        didSet {
            guard let day = day else { return }
            numberLabel.text = String(day.number)
            updateStyle(style)
        }
    }
    
    static let reuseIdentifier = String(describing: DayCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func updateStyle(_ newStyle: DayCellStyle) {
        style = newStyle
        guard let day = day else { return }
        UIView.animate(withDuration: 0.2) { [self] in
            if day.isToday {
                numberLabel.textColor = style.todayTextColor
                selectionBackgroundView.backgroundColor = style.todayBackgroundColor
            } else if isSelected {
                numberLabel.textColor = style.selectedTextColor
                selectionBackgroundView.backgroundColor = style.selectedBackgroundColor
            } else {
                selectionBackgroundView.backgroundColor = .clear
                numberLabel.textColor = day.isCurrentMonth ? style.textColor : style.inactiveTextColor
            }
        }
    }
    
    func configure() {
        numberLabel.font = style.font
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(numberLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        let selectionSize = min(frame.width, frame.height) - 25
        NSLayoutConstraint.activate([
            selectionBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: selectionSize),
            selectionBackgroundView.heightAnchor.constraint(equalToConstant: selectionSize),
        ])
        selectionBackgroundView.layer.cornerRadius = selectionSize / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
