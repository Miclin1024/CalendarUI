//
//  CalendarPageController.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import UIKit
import Combine

final class CalendarPageController: UIPageViewController {
    
    var configuration: Configuration.CalendarConfiguration
    
    unowned var calendarUI: CalendarUI
    
    private var pagePool = [CalendarState: Page]()
    
    private var stateSubscription: AnyCancellable!
    
    private var currentPage: Page! {
        let currentState = CalendarManager.main.state
        guard let page = pagePool[currentState] else {
            CalendarUILog.send(
                "Unable to find current calendar page",
                level: .error
            )
            return nil
        }
        
        return page
    }
    
    init(_ calendarUI: CalendarUI) {
        self.calendarUI = calendarUI
        configuration = calendarUI.configuration.calendarConfiguration
        super.init(transitionStyle: .scroll,
                   navigationOrientation: .horizontal, options: nil)
        CalendarManager.main.allowMultipleSelection =
            configuration.allowMultipleSelection
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        let initialVC = calendarPage(for: CalendarManager.main.state)
        setViewControllers([initialVC], direction: .forward,
                           animated: false, completion: nil)
        
//        stateSubscription = CalendarManager.main.$state
//            .dropFirst()
//            .sink { state in
//
//            }
    }
}

// MARK: Page Controller Data Source
extension CalendarPageController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CalendarPageController.Page
        let state = vc.state.prev
        return calendarPage(for: state)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CalendarPageController.Page
        let state = vc.state.next
        return calendarPage(for: state)
    }
}


// MARK: Page Controller Delegate
extension CalendarPageController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let vc = pageViewController.viewControllers!.first! as! Page
        CalendarManager.main.state = vc.state
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for vc in pendingViewControllers
            .compactMap({$0 as? Page}) {
            vc.updatePageIfNeeded()
        }
    }
}

// MARK: State Transition and Configuration Update
extension CalendarPageController {
    
    func updateConfiguration(_ configuration: Configuration.CalendarConfiguration) {
        self.configuration = configuration
        pagePool.values.forEach { $0.configuration = configuration }
    }
    
    func transition(to state: CalendarState, animated: Bool, completion: (()->Void)? = nil) {
        let currentState = CalendarManager.main.state
        guard currentState != state else { return }
        
        if CalendarState.sameMonthWithDifferentLayout(currentState, state) {
            // Perform an in-place transition if the target state is in the same month
            // and only differs by its layout.
            guard let page = pagePool[currentState] else {
                CalendarUILog.send(
                    "",
                    level: .error
                )
                return
            }
            
            page.transition(
                to: state,
                animated: animated,
                completion: {
                    // Update reuse pool about the mutation
                    self.pagePool.removeValue(forKey: currentState)
                    self.pagePool[state] = page
                    
                    CalendarManager.main.state = state
                    completion?()
                }
            )
        } else {
            // Otherwise, bring up a new page for the target calendar state.
            let page = calendarPage(for: state)
            let direction: UIPageViewController.NavigationDirection = currentState
                .firstDateInMonthOrWeek < state.firstDateInMonthOrWeek ?
                .forward : .reverse
            setViewControllers(
                [page], direction: direction,
                animated: animated, completion: { _ in
                    CalendarManager.main.state = state
                    completion?()
                }
            )
        }
    }
}

// MARK: Page Management
private extension CalendarPageController {
    
    func calendarPage(for state: CalendarState) -> Page {
        if let page = pagePool[state] {
            return page
        }
        
        let page = Page(calendarUI, state: state)
        pagePool[state] = page
        return page
    }
    
    func resizePool() {
        // TODO: Need to evict some pages if the pool gets too large. This should also trigger the recycle of cell within that page
    }
}
