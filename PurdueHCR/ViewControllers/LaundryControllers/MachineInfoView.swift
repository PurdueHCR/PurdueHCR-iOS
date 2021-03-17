//
//  MachineInfoView.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/2/21.
//  Copyright © 2021 DecodeProgramming. All rights reserved.
//

import UIKit

class MachineInfoView : UIView {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    // Views for the color indicators
    @IBOutlet weak var availableView: UIView!
    @IBOutlet weak var inUseView: UIView!
    @IBOutlet weak var finishingView: UIView!
    @IBOutlet weak var finishedView: UIView!
    @IBOutlet weak var outOfOrderView: UIView!
    
    
    var delegate : LaundryViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MachineInfo", owner: self, options: nil)
        addSubview(backgroundView)
        
        backgroundView.frame = self.bounds
        backgroundView.layer.cornerRadius = DefinedValues.radius
        
        let closeImage = #imageLiteral(resourceName: "SF_xmark").withRenderingMode(.alwaysTemplate)
        closeButton.setBackgroundImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.lightGray
        closeButton.setTitle("", for: .normal)
        
        // Initialize view colors
        availableView.backgroundColor = MachineStatus.available
        inUseView.backgroundColor = MachineStatus.inUse
        finishingView.backgroundColor = MachineStatus.finishing
        finishedView.backgroundColor = MachineStatus.finished
        outOfOrderView.backgroundColor = MachineStatus.outOfOrder
        
        let iconHeight = availableView.bounds.height
        let iconRadius = iconHeight / 2
        
        availableView.layer.cornerRadius = iconRadius
        inUseView.layer.cornerRadius = iconRadius
        finishingView.layer.cornerRadius = iconRadius
        finishedView.layer.cornerRadius = iconRadius
        outOfOrderView.layer.cornerRadius = iconRadius
        
    }
    
    @IBAction func closeView(_ sender: Any) {
        delegate?.dismissMachineInfoPopup()
    }
}
