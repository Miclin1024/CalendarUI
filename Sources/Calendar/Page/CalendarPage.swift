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
        
        var style = CalendarStyle()
        
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

// MARK: Collection View Layout
private extension CalendarPageController.Page {
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { index, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/7),
                heightDimension: .fractionalWidth(1/7/self.style.aspectRatio))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1/7/self.style.aspectRatio))
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
            cell.style = self.style
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
            cell.style = self.style
            return cell
        }
        
        let snapshot = generateSnapshot()
        dataSource.apply(snapshot, animatingDifferences: false,
                         completion: nil)
    }
    
    private func generateSnapshot() -> NSDiffableDataSourceSnapshot<Section, CalendarDay> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CalendarDay>()
        snapshot.appendSections([.main])
        let days = CalendarDayProvider.days(for: state)
        snapshot.appendItems(days)
        return snapshot
    }
}

// MARK: Collection View Delegate
extension CalendarPageController.Page: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        CalendarManager.main.selectedDates.insert(day)
        CalendarLog.send("Selected \(day)", level: .info)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        // Log a warning message if no day was removed from manager
        if CalendarManager.main.selectedDates.remove(day) == nil {
            CalendarLog.send("Calendar day not found in state management",
                             level: .warning)
        } else {
            CalendarLog.send("Deselected \(day)", level: .info)
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
        
    }
}
