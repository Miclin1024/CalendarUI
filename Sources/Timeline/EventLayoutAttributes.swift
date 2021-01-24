//
//  EventLayoutAttributes.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public final class EventLayoutAttributes {
    public let descriptor: EventDescriptor
    public var frame = CGRect.zero
    
    public init(_ descriptor: EventDescriptor) {
        self.descriptor = descriptor
    }
}

