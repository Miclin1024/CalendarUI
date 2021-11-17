//
//  CalendarDayGenerationTests.swift
//  CalendarUITests
//
//  Created by Michael Lin on 11/14/21.
//

import XCTest
@testable import CalendarUI

class CalendarDayGenerationTests: CalendarUITests {
    
    var monthLayoutTestState: CalendarState!
    
    var weekLayoutTestState: CalendarState!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let formatter = ISO8601DateFormatter()
        weekLayoutTestState = CalendarState (
            withLayout: .week,
            date: formatter.date(
                from: "2021-11-14T00:00:00+0000")!)
        
        monthLayoutTestState = CalendarState(
            withLayout: .month,
            date: formatter.date(
                from:"2021-11-1T00:00:00+0000")!)
    }

    override func tearDownWithError() throws {
    }
    
    func testWeekLayout() throws {
        var days = CalendarDayProvider
            .days(preceding: weekLayoutTestState)
        XCTAssertEqual(days.count, 0)
        
        days = CalendarDayProvider
            .days(following: weekLayoutTestState)
        XCTAssertEqual(days.count, 0)
        
        days = CalendarDayProvider.days(for: weekLayoutTestState)
        XCTAssertEqual(days.count, 7)
        
        XCTAssertEqual(days[0].date.ISO8601Format(),
                       "2021-11-14T00:00:00Z")
        XCTAssertEqual(days[6].date.ISO8601Format(),
                       "2021-11-20T00:00:00Z")
    }
    
    func testMonthLayout() throws {
        var days = CalendarDayProvider
            .days(preceding: monthLayoutTestState)
        XCTAssertEqual(days.count, 1)
        XCTAssertEqual(days[0].date.ISO8601Format(),
                       "2021-10-31T00:00:00Z")
        
        days = CalendarDayProvider
            .days(following: monthLayoutTestState)
        XCTAssertEqual(days.count, 4)
        XCTAssertEqual(days[0].date.ISO8601Format(),
                       "2021-12-01T00:00:00Z")
        XCTAssertEqual(days[3].date.ISO8601Format(),
                       "2021-12-04T00:00:00Z")
        
        days = CalendarDayProvider
            .days(for: monthLayoutTestState)
        XCTAssertEqual(days.count, 35)
        XCTAssertEqual(days[0].date.ISO8601Format(),
                       "2021-10-31T00:00:00Z")
        XCTAssertEqual(days[34].date.ISO8601Format(),
                       "2021-12-04T00:00:00Z")
    }
    
    func testIsToday() throws {
        let days = CalendarDayProvider
            .days(for: monthLayoutTestState)
        let calendar = CalendarManager.calendar
        let today = calendar.startOfDay(for: .now)
        for day in days {
            XCTAssertEqual(
                day.isToday,
                day.date.compare(today) == .orderedSame)
        }
    }
}
