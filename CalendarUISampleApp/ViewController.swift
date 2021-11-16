//
//  ViewController.swift
//  CalendarUISampleApp
//
//  Created by Michael Lin on 11/14/21.
//

import UIKit
import CalendarUI

class ViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let calendar = CalendarUI()
        addChild(calendar)
        stackView.addArrangedSubview(calendar.view)
    }
}

