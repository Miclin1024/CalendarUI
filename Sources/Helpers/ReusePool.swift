//
//  ReusePool.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import UIKit

final class ReusePool<T> where T: UIView {
    
    private var storage = [T]()
    
    func enqueue(views: [T]) {
        views.forEach {
            $0.frame = .zero
            storage.append($0)
        }
    }
    
    func dequeue() -> T {
        guard let item = storage.popLast() else {
            return T()
        }
        return item
    }
}
