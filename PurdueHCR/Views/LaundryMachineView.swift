//
//  LaundryMachineView.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 11/3/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

class LaundryMachineView: UIView {

    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    init(frame: CGRect) {

        timeRemainingLabel.text = ""
        backgroundImage.image = nil
    }

}
