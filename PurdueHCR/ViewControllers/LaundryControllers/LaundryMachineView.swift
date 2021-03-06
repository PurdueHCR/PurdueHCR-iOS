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
    @IBOutlet weak var machineNumberLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var statusColorView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("LaundryMachine", owner: self, options: nil)
        addSubview(backgroundView)
        //backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    
    }
    
}
