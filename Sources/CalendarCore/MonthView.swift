//
//  MonthView.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public protocol MonthViewDelegate: class {
    func monthView(_ monthView: MonthView<DayCell>, willSelectDay day: Day, at indexPath: IndexPath)
    func monthView(_ monthView: MonthView<DayCell>, willDeselectDay day: Day, at indexPath: IndexPath)
}

open class MonthView<Cell>: UICollectionViewController, UICollectionViewDelegateFlowLayout where Cell: DayCell {
    
    open private(set) var month: Date
    
    open weak var delegate: MonthViewDelegate?
    
    var days: [Day]
    
    var style = MonthViewStyle()
    
    let calendar = NSCalendar.current
    
    required public init(date: Date) {
        
        let normalizedMonth = calendar.getMonth(fromDate: date)!
        self.month = normalizedMonth
        self.days = MonthView.generateDays(forMonth: normalizedMonth)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        super.init(collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = style.backgroundColor
        
        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = style.allowMultipleSelection
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }
    
    // MARK: UICollectionViewDataSource
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        cell.day = self.days[indexPath.item]
        cell.updateStyle(style.dayCellStyle)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell
        let castedSelf = self as! MonthView<DayCell>
        delegate?.monthView(castedSelf, willSelectDay: cell.day, at: indexPath)
        return true
    }
    
    open override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell
        let castedSelf = self as! MonthView<DayCell>
        delegate?.monthView(castedSelf, willDeselectDay: cell.day, at: indexPath)
        return true
    }
    
    // MARK: Style Update
    
    func updateStyle(_ newStyle: MonthViewStyle) {
        style = newStyle
        view.backgroundColor = style.backgroundColor
        collectionView.allowsMultipleSelection = style.allowMultipleSelection
        collectionView.reloadData()
    }
    
    // MARK: Days Generation
    
    static private func generateDays(forMonth month: Date) -> [Day] {
        let calendar = NSCalendar.current
        let month = calendar.getMonth(fromDate: month)!
        let firstDay = month
        let lastDay = calendar.getLastDayInMonth(fromDate: month)!
        
        let startingWeekday = calendar.component(.weekday, from: month)
        
        var days: [Day] = []
        
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
        
        return days
    }
}
