//
//  EventProvider.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public protocol EventsProvider: class {
    func calendar(_ calendar: MKCalendar, eventsForDate date: Date) -> [EventDescriptor]
}

public protocol EventDescriptor: AnyObject {
    var startDate: Date { get set }
    var endDate: Date { get set }
    var isAllDay: Bool { get }
    var text: String { get }
    var attributedText: NSAttributedString? { get }
    var lineBreakMode: NSLineBreakMode? { get }
    var font : UIFont { get }
    var color: UIColor { get }
    var textColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var editedEvent: EventDescriptor? { get set }
    func makeEditable() -> Self
    func commitEditing()
}
