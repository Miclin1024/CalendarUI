//
//  EventResizeHandleView.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

public final class EventResizeHandleView: UIView {
    public lazy var panGestureRecognizer = UIPanGestureRecognizer()
    public lazy var dotView = EventResizeHandleDotView()
    
    public var borderColor: UIColor? {
        get {
            return dotView.borderColor
        }
        set(value) {
            dotView.borderColor = value
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = 10
        let centerD = (bounds.width - radius) / 2
        let origin = CGPoint(x: centerD, y: centerD)
        let dotSize = CGSize(width: radius, height: radius)
        dotView.frame = CGRect(origin: origin, size: dotSize)
    }
    
    private func configure() {
        addSubview(dotView)
        clipsToBounds = false
        backgroundColor = .clear
        addGestureRecognizer(panGestureRecognizer)
    }
    
}
