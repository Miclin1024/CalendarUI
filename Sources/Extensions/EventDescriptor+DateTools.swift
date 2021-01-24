//
//  EventDescriptor+DateTools.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation

extension EventDescriptor {
    var datePeriod: ClosedRange<Date> {
        return startDate ... endDate
    }
}
