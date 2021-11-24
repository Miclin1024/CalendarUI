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
        
        var configuration = Configuration.CalendarConfiguration()
        
        var calendarCollection: CalendarCollectionView!
        
        var dataSource: UICollectionViewDiffableDataSource<
            Section, CalendarDay
        >!
        
        init(_ calendarUI: CalendarUI, state: CalendarState) {
            self.calendarUI = calendarUI
            self.state = state
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
                frame: view.bounds,
                collectionViewLayout: createLayout())
            configureDataSource()
            calendarCollection.delegate = self
            
            view.addSubview(calendarCollection)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            calendarCollection.frame = view.bounds
        }
    }
}

// MARK: Views Update
extension CalendarPageController.Page {
    
    /**
     Update the calendar view immediately.
     
     This includes performing any layout updates, syncing the day selections, etc.
     */
    func updateViewIfNeeded() {
        let range = state.dateRange
        let syncDays = CalendarManager.main.selectedDays
            .filter { range.contains($0.date) }
        syncCalendarSelection(withDays: syncDays)

        // TODO: Finish this function
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
        
        selectDays(Array(daysToSelect), animated: false)
        deselectDays(Array(daysToDeselect), animated: false)
    }
    
    /**
     Select the days on the calendar page.
     
     The method will silently fail if the page doesn't contain any of the days in the argument. However, atomicity is not enforced.
     */
    func selectDays(_ days: [CalendarDay], animated: Bool) {
        let range = state.dateRange
        
        for day in days {
            guard range.contains(day.date) else {
                CalendarLog.send(
                    "Can't select date on a calendar page that doesn't contain it",
                    level: .warning)
                return
            }
            
            guard let indexPath = dataSource.indexPath(for: day) else {
                CalendarLog.send(
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
                CalendarLog.send(
                    "Can't deselect date on a calendar page that doesn't contain it",
                    level: .warning)
                return
            }
            
            guard let indexPath = dataSource.indexPath(for: day) else {
                CalendarLog.send(
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
private extension CalendarPageController.Page {
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { index, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/7),
                heightDimension: .fractionalWidth(1/7/self.configuration.aspectRatio))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1/7/self.configuration.aspectRatio))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item, count: 7)
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}

// MARK: Collection View Data Source
private extension CalendarPageController.Page {
    
    func configureDataSource() {
        let registration = UICollectionView.CellRegistration<
            DefaultCalendarCell, CalendarDay
        >() { [unowned self] cell, indexPath, day in
            cell.configuration = self.configuration
            cell.configure(using: day, state: self.state)
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
        
        let snapshot = generateSnapshot()
        dataSource.apply(snapshot, animatingDifferences: false,
                         completion: nil)
    }
    
    func generateSnapshot() -> NSDiffableDataSourceSnapshot<Section, CalendarDay> {
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
        
        return state.dateRange.contains(day.date)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        CalendarManager.main.handleUserSelectDay(day)
        CalendarLog.send(
            "Selected \(day)", level: .info)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        // Log a warning message if no day was removed from manager
        if !CalendarManager.main.handleUserDeselectDay(day) {
            CalendarLog.send(
                "Calendar day not found in state management",
                level: .warning)
        } else {
            CalendarLog.send(
                "Deselected \(day)", level: .info)
        }
    }
}


