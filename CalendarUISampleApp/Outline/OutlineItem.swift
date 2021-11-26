//
//  OutlineItem.swift
//  CalendarUISampleApp
//
//  Created by Michael Lin on 11/25/21.
//

import UIKit

class OutlineItem: Hashable {
    
    let title: String
    
    let subitems: [OutlineItem]
    
    let targetController: UIViewController.Type?
    
    private let identifier = UUID()
    
    init(title: String,
         viewController: UIViewController.Type? = nil,
         subitems: [OutlineItem] = []) {
        self.title = title
        self.subitems = subitems
        self.targetController = viewController
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: OutlineItem, rhs: OutlineItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
