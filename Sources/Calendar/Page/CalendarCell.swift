//
//  CalendarCell.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import UIKit

open class CalendarCell: UICollectionViewCell {
    
    open override func prepareForReuse() {
        CalendarManager.main.calendarCellReusePool.enqueue(views: [self])
    }
}
