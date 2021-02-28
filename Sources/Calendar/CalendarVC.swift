//
//  CalendarVC.swift
//  MKCalendar
//
//  Created by Michael Lin on 2/27/21.
//

import UIKit

public protocol CalendarVCDelegate: class {
    func calendarVC(_ calendarVC: CalendarVC, didSelectDay day: Day)
    func calendarVC(_ calendarVC: CalendarVC, didDeselectDay day: Day)
}

open class CalendarVC: UIViewController {

    enum Section {
        case main
    }
    
    let calendar = NSCalendar.current
    
    weak var delegate: CalendarVCDelegate?

    var displayMode: MKCalendar.DisplayMode
    var startingDate: Date
    var calendarCollectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, Day>!
    
    private(set) var style: CalendarViewStyle
    
    
    required public init(
        displayMode: MKCalendar.DisplayMode,
        startingDate: Date,
        style: CalendarViewStyle = CalendarViewStyle()) {
        self.displayMode = displayMode
        self.startingDate = startingDate
        self.style = style
        
        super.init(nibName: nil, bundle: nil)
        configureCollectionView()
        configureDataSource()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = style.backgroundColor
    }
}

// MARK: Collection View Configuration
extension CalendarVC {
    private func configureCollectionView() {
        calendarCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        calendarCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        calendarCollectionView.backgroundColor = .clear
        calendarCollectionView.isScrollEnabled = false
        calendarCollectionView.allowsMultipleSelection = true
        calendarCollectionView.delegate = self
        calendarCollectionView.register(DayCell.self, forCellWithReuseIdentifier: DayCell.reuseIdentifier)
        
        view.addSubview(calendarCollectionView)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Day>(collectionView: calendarCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Day) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.reuseIdentifier, for: indexPath) as? DayCell else { fatalError("Couldn't create day cell") }
            cell.day = identifier
            cell.updateStyle(self.style.dayCellStyle)
            return cell
        }
        
        dataSource.apply(snapshotForCurrentState(), animatingDifferences: false)
    }
    
    private func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, Day> {
        let days = generateDays()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Day>()
        snapshot.appendSections([.main])
        snapshot.appendItems(days)
        return snapshot
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/7))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}

// MARK: View Update
extension CalendarVC {
    func updateStyle(_ newStyle: CalendarViewStyle) {
        style = newStyle
        view.backgroundColor = style.backgroundColor
        calendarCollectionView.reloadData()
    }
    
    func updateDisplay(_ displayMode: MKCalendar.DisplayMode, startingDate: Date,
                       animated: Bool = true, completion: (()->Void)? = nil) {
        self.displayMode = displayMode
        self.startingDate = startingDate
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
}

// MARK: Days Generation
extension CalendarVC {
    private func generateDays() -> [Day] {
        var days: [Day] = []
        switch displayMode {
        case .month:
            let firstDay = startingDate
            let lastDay = calendar.getLastDayInMonth(fromDate: startingDate)!
            
            let startingWeekday = calendar.component(.weekday, from: startingDate)
            
            for offset in stride(from: startingWeekday - 1, to: 0, by: -1) {
                let date = calendar.date(byAdding: .day, value: -offset, to: firstDay)!
                let dayValue = calendar.component(.day, from: date)
                let isToday = calendar.isDateInToday(date)
                days.append(Day(date: date, number: dayValue, isCurrentMonth: false, isToday: isToday))
            }
            
            for date in calendar.datesBetween(firstDay, through: lastDay, byAdding: .day, value: 1) {
                let dayValue = calendar.component(.day, from: date)
                let isToday = calendar.isDateInToday(date)
                days.append(Day(date: date, number: dayValue, isCurrentMonth: true, isToday: isToday))
            }
            
            let endingWeekday = calendar.component(.weekday, from: lastDay)
            for offset in 1 ..< 8 - endingWeekday {
                let date = calendar.date(byAdding: .day, value: offset, to: lastDay)!
                let dayValue = calendar.component(.day, from: date)
                let isToday = calendar.isDateInToday(date)
                days.append(Day(date: date, number: dayValue, isCurrentMonth: false, isToday: isToday))
            }
            
        case .week:
            for offset in 0 ..< 7 {
                let date = calendar.date(byAdding: .day, value: offset, to: startingDate)!
                let dayValue = calendar.component(.day, from: date)
                let isToday = calendar.isDateInToday(date)
                days.append(Day(date: date, number: dayValue, isCurrentMonth: true, isToday: isToday))
            }
        }
        
        return days
    }
}

// MARK: Collection View Delegate
extension CalendarVC: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.calendarVC(self, didSelectDay: day)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let day = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.calendarVC(self, didDeselectDay: day)
    }
}
