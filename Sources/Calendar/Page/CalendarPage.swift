//
//  CalendarPage.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/14/21.
//

import Foundation
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
            calendarCollection.backgroundColor = .clear
            configureDataSource()
            
            view.addSubview(calendarCollection)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            calendarCollection.frame = view.bounds
        }
    }
}

// MARK: Collection View Layout
extension CalendarPageController.Page {
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
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
extension CalendarPageController.Page {
    
    private func configureDataSource() {
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
            return cv.dequeueConfiguredReusableCell(
                using: registration, for: indexPath, item: day)
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

// MARK: Views Update
extension CalendarPageController.Page {
    
    /**
     Update the calendar view immediately.
     
     This includes performing any layout updates, syncing the day selections, etc.
     */
    func updateViewIfNeeded() {
        
    }
}
