//
//  View+StackView.swift
//  MKCalendar
//
//  Created by Michael Lin on 1/23/21.
//

import Foundation
import UIKit

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis = .vertical,
                     distribution: UIStackView.Distribution = .fill,
                     alignment: UIStackView.Alignment = .fill,
                     spacing: CGFloat = 0,
                     subviews: [UIView] = []) {
        self.init(arrangedSubviews: subviews)
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
}
