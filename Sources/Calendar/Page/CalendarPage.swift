//
//  CalendarPage.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import UIKit

extension CalendarPageController {
    
    final class Page: UIViewController {
        
        enum Section {
            case main
        }
        
        unowned var calendarUI: CalendarUI
        
        var state: CalendarState
        
        var configuration: Configuration.CalendarConfiguration {
            didSet {
                if oldValue != configuration {
                    setNeedsUpdatePage()
                }
            }
        }
        
        var calendarCollection: CalendarCollectionView!
        
        var dataSource: UICollectionViewDiffableDataSource<
            Section, CalendarDay
        >!
        
        lazy var pageHeight: CGFloat = {
            return configuration
                .preferredHeightForCell * 5
        }()
        
        private var needsUpdatePage = false
        
        init(_ calendarUI: CalendarUI, state: CalendarState) {
            self.calendarUI = calendarUI
            self.state = state
            configuration = calendarUI.configuration.calendarConfiguration
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func loadView() {
            super.loadView()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .clear
            
            calendarCollection = CalendarCollectionView(
                frame: .zero,
                collectionViewLayout: createLayout())
            configureDataSource()
            calendarCollection.delegate = self
            
            view.addSubview(calendarCollection)
            
            let _ = CalendarManager.main.$selectedDays.sink { _ in
                self.setNeedsUpdatePage()
            }
            
            // Perform an update for all newly created pages
            updatePage()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            calendarCollection.frame = CGRect(
                origin: .zero,
                size: CGSize(
                    width: view.bounds.width,
                    height: pageHeight))
            calendarCollection.collectionViewLayout.invalidateLayout()
            calendarCollection.setCollectionViewLayout(
                createLayout(), animated: false)

        }
    }
}

// MARK: Calendar Page Update
extension CalendarPageController.Page {
    
    /**
     Perform an in-place transition of the calendar page to a new state.
     */
    func transition(to state: CalendarState, animated: Bool, completion: (()->Void)? = nil) {
        guard CalendarState.shouldUseInPlaceTransition(state, self.state) else {
            CalendarUILog.send(
                "Unexpected state for in-place page transition",
                level: .error)
            return
        }
        
        let snapshot = generateSnapshot(for: state)
        dataSource.apply(
            snapshot, animatingDifferences: animated,
            completion: {
                self.state = state
                self.calendarCollection
                    .invalidateIntrinsicContentSize()
                completion?()
            }
        )
    }
    
    /**
     Update the calendar page immediately.
     
     This includes performing any layout updates, day selections sync, etc.
     */
    func updatePageIfNeeded() {
        if needsUpdatePage {
            updatePage()
        }
    }
    
    private func updatePage() {
        let range = state.dateRange
        let syncDays = CalendarManager.main.selectedDays
            .filter { range.contains($0.date) }
        syncCalendarSelection(withDays: syncDays)

        calendarCollection.allowsMultipleSelection = configuration.allowMultipleSelection
    }
    
    private func setNeedsUpdatePage() {
        needsUpdatePage = true
    }
    
    /**
     Sync the calendar selection with days, selecting or deselected cells if needed.
     */
    private func syncCalendarSelection(withDays days: Set<CalendarDay>) {
        var daysToSelect = days
        var daysToDeselect = Set<CalendarDay>()
        let paths = calendarCollection
            .indexPathsForSelectedItems
        if let paths = paths {
            for indexPath in paths {
                let day = dataSource
                    .itemIdentifier(for: indexPath)!
                /**
                 If a day is already selected, and is on the list of
                 daysToSelect, we will remove it from the list since there's
                 no need to reselect it.
                 
                 But if a selected day is not on the list, that means this
                 selection is out-of-sync and should be deselected.
                 */
                if daysToSelect.contains(day) {
                    daysToSelect.remove(day)
                } else {
                    daysToDeselect.update(with: day)
                }
            }
        }
        
        UIView.performWithoutAnimation {
            selectDays(Array(daysToSelect), animated: false)
            deselectDays(Array(daysToDeselect), animated: false)
        }
    }
    
    /**
     Select the days on the calendar page.
     
     The method will silently fail if the page doesn't contain any of the days in the argument. However, atomicity is not enforced.
     */
    func selectDays(_ days: [CalendarDay], animated: Bool) {
        let range = state.dateRange
        
        for day in days {
            guard range.contains(day.date) else {
                CalendarUILog.send(
                    "Can't select date on a calendar page that doesn't contain it",
                    level: .warning)
                return
            }
            
            guard let indexPath = dataSource.indexPath(for: day) else {
                CalendarUILog.send(
                    "Can't find index path for calendar day",
                    level: .error)
                return
            }
            
            calendarCollection.selectItem(
                at: indexPath, animated: animated,
                scrollPosition: .centeredHorizontally)
        }
    }
    
    /**
     Deselect the days on the calendar page.
     
     The method will silently fail if the page doesn't contain any of the days in the argument. However, atomicity is not enforced.
     */
    func deselectDays(_ days: [CalendarDay], animated: Bool) {
        let range = state.dateRange
        
        for day in days {
            guard range.contains(day.date) else {
                CalendarUILog.send(
                    "Can't deselect date on a calendar page that doesn't contain it",
                    level: .warning)
                return
            }
            
            guard let indexPath = dataSource.indexPath(for: day) else {
                CalendarUILog.send(
                    "Can't find index path for calendar day",
                    level: .error)
                return
            }
            
            calendarCollection.deselectItem(
                at: indexPath, animated: animated)
        }
    }
}

// MARK: Collection View Layout
extension CalendarPageController.Page {
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        // Floor to avoid floating-point error that would cause
        // row to overflow
        let width = floor(view.bounds.width / CGFloat(7))
        let height = pageHeight /
        CGFloat(numberOfRows(in: state))
        layout.itemSize = CGSize(width: width, height: height)
        
        return layout
    }
    
    private func numberOfRows(in state: CalendarState) -> Int {
        if state.layout == .week {
            return 1
        } else {
            let calendar = CalendarManager.calendar
            let range = calendar.range(of: .weekOfMonth, in: .month,
                           for: state.firstDateInMonthOrWeek)!
            return range.count
        }
    }
}

// MARK: Collection View Data Source
private extension CalendarPageController.Page {
    
    func configureDataSource() {
        let registration = UICollectionView.CellRegistration<
            DefaultCalendarCell, CalendarDay
        >() { [unowned self] cell, indexPath, day in
            UIView.performWithoutAnimation {
                cell.configuration = self.configuration
                cell.configure(using: day, state: self.state)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<
            Section, CalendarDay
        >(collectionView: calendarCollection) { [unowned self]
            cv, indexPath, day in
            if let customCellDataSource = CalendarManager
                .main.calendarDataSource {
                return customCellDataSource.calendar(
                    self.calendarUI, cellForDay: day)
            }
            let cell = cv.dequeueConfiguredReusableCell(
                using: registration, for: indexPath, item: day)
            cell.configuration = self.configuration
            return cell
        }
        
        let snapshot = generateSnapshot(for: self.state)
        dataSource.apply(snapshot, animatingDifferences: false,
                         completion: nil)
    }
    
    func generateSnapshot(for state: CalendarState) -> NSDiffableDataSourceSnapshot<Section, CalendarDay> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CalendarDay>()
        snapshot.appendSections([.main])
        let days = CalendarDayProvider.days(for: state)
        snapshot.appendItems(days)
        return snapshot
    }
}

// MARK: Collection View Delegate
extension CalendarPageController.Page: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let day = dataSource.itemIdentifier(for: indexPath) else {
            return false
        }
        
        if !state.dateRange.contains(day.date) {
            let targetState = day.date > state.firstDateInMonthOrWeek ?
            state.next : state.prev
            calendarUI.transition(to: targetState, animated: true)
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        CalendarManager.main.handleUserSelectDay(day)
        CalendarUILog.send(
            "Selected \(day)", level: .info)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        // Log a warning message if no day was removed from manager
        if !CalendarManager.main.handleUserDeselectDay(day) {
            CalendarUILog.send(
                "Calendar day not found in state management",
                level: .warning)
        } else {
            CalendarUILog.send(
                "Deselected \(day)", level: .info)
        }
    }
}


