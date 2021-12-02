//
//  CalendarCollectionView.swift
//  CalendarUI
//
//  Created by Michael Lin on 11/15/21.
//

import UIKit

class CalendarCollectionView: UICollectionView {
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .clear
        isScrollEnabled = false
        allowsSelection = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
