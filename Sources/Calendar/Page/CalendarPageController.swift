//
//  CalendarPageController.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import UIKit

final class CalendarPageController: UIPageViewController {
    
    var style = CalendarStyle()
    
    unowned var calendarUI: CalendarUI
    
    private var pagePool = [CalendarState: Page]()
    
    init(_ calendarUI: CalendarUI) {
        self.calendarUI = calendarUI
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
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
}

// MARK: Page Management
private extension CalendarPageController {
    
    func calendarPage(for state: CalendarState) -> Page {
        if let page = pagePool[state] {
            page.updateViewIfNeeded()
            return page
        }
        
        let page = Page(calendarUI, state: state)
        pagePool[state] = page
        return page
    }
    
    func resizePool() {
        // TODO: Need to evict some pages if the pool gets too large
    }
}
