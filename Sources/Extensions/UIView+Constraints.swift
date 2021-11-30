//
//  UIView+Constraints.swift
//  CalendarUISampleApp
//
//  Created by Michael Lin on 11/29/21.
//

import UIKit

extension UIView {
    
    func constraints(to view: UIView, margin: NSDirectionalEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
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
        ])
    }
}
