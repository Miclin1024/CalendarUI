//
//  EventEditingSnappingBehavior.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation

public protocol EventEditingSnappingBehavior {
    init(_ calendar: Calendar)
    func nearestDate(to date: Date) -> Date
    func accentedHour(for date: Date) -> Int
    func accentedMinute(for date: Date) -> Int
}
