//
//  UIView+Constraints.swift
//  CalendarUISampleApp
//
//  Created by Michael Lin on 11/29/21.
//

import UIKit

extension UIView {
    
    @discardableResult
    func constraints(to view: UIView, margin: NSDirectionalEdgeInsets = .zero) -> (leading: NSLayoutConstraint, top: NSLayoutConstraint, trailing: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: margin.leading
            ),
            topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: margin.top
            ),
            trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -margin.trailing
            ),
            bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -margin.bottom
            )
        ]
        NSLayoutConstraint.activate(constraints)
        return (
            constraints[0], constraints[1],
            constraints[2], constraints[3]
        )
    }
}
