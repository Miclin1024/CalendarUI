//
//  Array+Shift.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation

extension Array {
    mutating func shift(_ amount: Int) {
        var amount = amount
        guard -count...count ~= amount else { return }
        if amount < 0 { amount += count }
        self = Array(self[amount ..< count] + self[0 ..< amount])
    }
}
