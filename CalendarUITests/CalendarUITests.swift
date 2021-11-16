//
//  CalendarUITests.swift
//  CalendarUITests
//
//  Created by Michael Lin on 11/14/21.
//

import XCTest
@testable import CalendarUI

class CalendarUITests: XCTestCase {

    override func setUpWithError() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        CalendarManager.main.calendar = calendar
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
