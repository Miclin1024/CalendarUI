//
//  CalendarStateTests.swift
//  CalendarUITests
//
//  Created by Michael Lin on 11/15/21.
//

import XCTest
@testable import CalendarUI

class CalendarStateTests: CalendarUITests {
    
    let testDate: Date = {
        let iSODate = "2021-11-15T00:00:00+0000"
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: iSODate)!
    }()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStateFactoryInit() throws {
        let lhs = CalendarState(withLayout: .month, date: testDate)
        let rhs = CalendarState(withLayout: .month, date: testDate)
        let notEqual = CalendarState(withLayout: .week, date: testDate)
        XCTAssertTrue(lhs == rhs)
        XCTAssertFalse(lhs == notEqual)
    }
    
    func testStateTransitionMonth() throws {
        let current = CalendarState(withLayout: .month, date: testDate)
        let next = current.next
        XCTAssertTrue(next.layout == .month)
        XCTAssertEqual(next.firstDateInMonthOrWeek.ISO8601Format(),
                       "2021-12-01T00:00:00Z")
        let prev = current.prev
        XCTAssertTrue(prev.layout == .month)
        XCTAssertEqual(prev.firstDateInMonthOrWeek.ISO8601Format(),
                       "2021-10-01T00:00:00Z")
    }
    
    func testStateTransitionWeek() throws {
        let current = CalendarState(withLayout: .week, date: testDate)
        let next = current.next
        XCTAssertTrue(next.layout == .week)
        XCTAssertEqual(next.firstDateInMonthOrWeek.ISO8601Format(),
                       "2021-11-21T00:00:00Z")
        let prev = current.prev
        XCTAssertTrue(prev.layout == .week)
        XCTAssertEqual(prev.firstDateInMonthOrWeek.ISO8601Format(),
                       "2021-11-07T00:00:00Z")
    }
}
