//
//  PointDescriptionView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/26/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class PointDescriptionView: UIView {
    @IBOutlet var residentLabel: UILabel!
    @IBOutlet var pointTypeDescriptionLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("PointDescriptionView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setLog(pointLog:PointLog)
    {
        residentLabel.text = pointLog.resident
        pointTypeDescriptionLabel.text = pointLog.type.pointDescription
        descriptionLabel.text = pointLog.pointDescription
        descriptionLabel.layer.borderColor = UIColor.black.cgColor
        descriptionLabel.layer.borderWidth = 1.0
		descriptionLabel.layer.cornerRadius = 10
    }
    

    
}
