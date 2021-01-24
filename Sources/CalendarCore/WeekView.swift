//
//  WeekView.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public protocol WeekViewDelegate: class {
    func weekView(_ weekView: WeekView<DayCell>, willSelectDay day: Day, at indexPath: IndexPath)
    
    func weekView(_ weekView: WeekView<DayCell>, willDeselectDay day: Day, at indexPath: IndexPath)
}

open class WeekView<Cell>: UICollectionViewController, UICollectionViewDelegateFlowLayout where Cell: DayCell {

    private(set) var week: Date
    
    public weak var delegate: WeekViewDelegate?
    
    var days: [Day]
    
    var style = WeekViewStyle()
    
    let calendar = NSCalendar.current
    
    required public init(date: Date) {
        
        let normalizedWeek = calendar.getFirstDayOfWeek(fromDate: date)!
        self.week = normalizedWeek
        self.days = WeekView.generateDays(forWeek: normalizedWeek)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        super.init(collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = style.backgroundColor
        
        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }

    // MARK: UICollectionViewDataSource

    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        cell.day = self.days[indexPath.item]
        cell.updateStyle(style.dayCellStyle)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: UICollectionViewDelegate
    
    override open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell

        let castedSelf = self as! WeekView<DayCell>
        
        delegate?.weekView(castedSelf, willSelectDay: cell.day, at: indexPath)
        return true
    }
    
    override open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell
        let castedSelf = self as! WeekView<DayCell>
        delegate?.weekView(castedSelf, willDeselectDay: cell.day, at: indexPath)
        return true
    }
    
    // MARK: Style Update
    
    func updateStyle(_ newStyle: WeekViewStyle) {
        style = newStyle
        view.backgroundColor = style.backgroundColor
        collectionView.reloadData()
    }
    
    // MARK: Days Generation

    static func generateDays(forWeek week: Date) -> [Day] {
        let calendar = NSCalendar.current
        let firstDay = calendar.getFirstDayOfWeek(fromDate: week)!
        
        var days: [Day] = []
        
        for offset in 0 ..< 7 {
            let date = calendar.date(byAdding: .day, value: offset, to: firstDay)!
            let dayValue = calendar.component(.day, from: date)
            let isToday = calendar.isDateInToday(date)
            days.append(Day(date: date, number: dayValue, isCurrentMonth: true, isToday: isToday))
        }
        
        return days
    }
}
