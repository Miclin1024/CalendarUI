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
    
    public var currentState: CalendarState {
        CalendarManager.main.state
    }
    
    var headerView: HeaderView!
    
    var timelineView: TimelineContainer!
    
    var calendarPageController: CalendarPageController!
    
    var configuration: Configuration
    
    public init(initialState state: CalendarState? = nil,
                configuration: Configuration = .init()) {
        CalendarManager.initialize(withState: state)
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        CalendarManager.initialize()
        self.configuration = Configuration()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        CalendarManager.initialize()
        self.configuration = Configuration()
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        headerView = HeaderView(
            configuration: configuration.headerConfiguration)
        calendarPageController = CalendarPageController(self)
        timelineView = TimelineContainer()
        
        
        configureViews()
    }
}

// MARK: - View Configuration
private extension CalendarUI {
    
    func configureViews() {
        
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = configuration.headerBottomSpacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = configuration.margin
        
        stackView.addArrangedSubview(headerView)
        
        addChild(calendarPageController)
        stackView.addArrangedSubview(calendarPageController.view)
        calendarPageController.didMove(toParent: self)
        
        let bottomConstraint = stackView.bottomAnchor
            .constraint(equalTo: view.bottomAnchor)
        bottomConstraint.priority = .defaultLow - 1
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }
}

// MARK: - Calendar Cell Management
public extension CalendarUI {
    
    struct CellRegistration<Cell> where Cell: CalendarCell {
        
        public typealias Handler = (_ cell: Cell, _ day: CalendarDay) -> Void
        
        public let handler: Handler
        
        let reusePool = ReusePool<Cell>()
        
        public init(handler: @escaping Handler) {
            self.handler = handler
        }
    }
    
    func dequeueConfiguredReusableCell<Cell: CalendarCell>(using registration: CellRegistration<Cell>, day: CalendarDay) -> Cell {
        let pool = CalendarManager.main.fetchReusePool(for: Cell.self)
        let cell = pool.dequeue()
        registration.handler(cell, day)
        return cell
    }
}

// MARK: - Calendar Transition
public extension CalendarUI {
    
    func transition(to state: CalendarState, animated: Bool) {
        calendarPageController.transition(to: state, animated: animated, completion: nil)
    }
}
