//
//  CalendarCell.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import UIKit

open class CalendarCell: UICollectionViewCell {
    
    var configuration = Configuration.CalendarConfiguration()
    
    open override func prepareForReuse() {
        let pool = CalendarManager.main.fetchReusePool(for: type(of: self))
        pool.enqueue(views: [self])
    }
    
    func configure(using day: CalendarDay, state: CalendarState) {}
}
