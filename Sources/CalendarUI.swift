//
//  CalendarUI.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import UIKit

public protocol CalendarUIDataSource: AnyObject {
    func calendar(_ calendar: CalendarUI, cellForDay: CalendarDay) -> CalendarCell
}

public final class CalendarUI: UIViewController {
    
    public var dataSource: CalendarUIDataSource? {
        get {
            CalendarManager.main.calendarDataSource
        }
        
        set {
            CalendarManager.main.calendarDataSource = newValue
        }
    }
    
    let headerView = HeaderView()
    
    let timelineView = TimelineContainer()
    
    let style = CalendarUIStyle()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
}

// MARK: - View Configuration
extension CalendarUI {
    private func configureViews() {
        
        // 
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = style.headerBottomSpacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        view.addSubview(stackView)
        stackView.frame = view.bounds
            .inset(by: style.contentInset)
        
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(timelineView)
    }
}

// MARK: - CalendarCell Registration
extension CalendarUI {
    public struct CellRegistration<Cell> where Cell: CalendarCell {
        
        public typealias Handler = (_ cell: Cell, _ day: CalendarDay) -> Void
        
        public let handler: Handler
        
        let reusePool = ReusePool<Cell>()
        
        public init(handler: @escaping Handler) {
            self.handler = handler
        }
    }
}

// MARK: - CalendarCell Dequeue
extension CalendarUI {
    public func dequeueConfiguredReusableCell<Cell>(using registration: CellRegistration<Cell>, day: CalendarDay) -> Cell where Cell: CalendarCell {
        let pool = CalendarManager.main.calendarCellReusePool
        guard let cell = pool.dequeue() as? Cell else {
            fatalError("Multi-cell calendar currently not supported")
        }
        registration.handler(cell, day)
        return cell
    }
}
