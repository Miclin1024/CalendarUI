//
//  HeaderView.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import UIKit
import Combine

final class HeaderView: UIView {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    private var weekdaySymbolLabels: [UILabel] = {
        (0..<7).map { _ in
            let label = UILabel()
            label.textAlignment = .center
            return label
        }
    }()
    
    private var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var spacingConstraint: NSLayoutConstraint!
    
    private var titleSubscription: AnyCancellable!
    
    var style = HeaderStyle()
    
    override var intrinsicContentSize: CGSize {
        let height = titleLabel.intrinsicContentSize.height
        + style.spacing
        + weekdaySymbolLabels.first!.intrinsicContentSize.height
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    convenience init() {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        configureViews()
    }
}

// MARK: - View Configuration
private extension HeaderView {
    
    func configureViews() {
        
        // Title Label
        titleLabel.textColor = style.titleColor
        titleLabel.font = style.titleFont
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor
                .constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor
                .constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor
                .constraint(equalTo: topAnchor)
        ])
        
        titleSubscription = Publishers.CombineLatest(
            CalendarManager.main.$state, CalendarManager.main.$selectedDays
        ).sink { [weak self] (state, selectedDates) in
            guard let self = self else { return }
            let prevDate = CalendarManager.main.state.firstDateInMonthOrWeek
            let date = state.firstDateInMonthOrWeek
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "MMMM, y"
            self.titleLabel.text = formatter.string(from: date)
        }
        
        // Weekday symbols stack view
        addSubview(stackView)
        spacingConstraint = stackView.topAnchor
            .constraint(equalTo: titleLabel.bottomAnchor,
                        constant: style.spacing)
        spacingConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor
                .constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor
                .constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor
                .constraint(equalTo: bottomAnchor)
        ])
        
        for (idx, symbol) in style.symbolStyle
                .symbols.enumerated() {
            let label = weekdaySymbolLabels[idx]
            label.textColor = style.symbolColor
            label.font = style.symbolFont
            label.text = symbol
            self.stackView.addArrangedSubview(label)
        }
    }
}

// MARK: Animations
private extension HeaderView {
    
    enum TitleFadeTransitionDirection {
        case left, right
    }
    
    func titleFadeTransition(from direction: TitleFadeTransitionDirection, newTextValue: String) {
        // TODO: Title transition animation
    }
}
