//
//  PointDescriptionView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/26/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PointDescriptionView: UIView {
    
    weak var delegate: CustomViewDelegate?
    
    @IBOutlet var residentLabel: UILabel!
	@IBOutlet weak var dateOccurredLabel: UILabel!
	@IBOutlet var pointTypeDescriptionLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
	@IBOutlet weak var grayView: UIView!
	@IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var dateSubmittedLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    
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
		self.backgroundView.layer.cornerRadius = 10
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		icon.backgroundColor = DefinedValues.systemBlue
		icon.layer.cornerRadius = icon.layer.frame.height / 2
		icon.image = #imageLiteral(resourceName: "Send")
		grayView.layer.cornerRadius = DefinedValues.radius
		grayView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if (User.get(.permissionLevel) as! Int != PointType.PermissionLevel.rhp.rawValue) {
            editButton.isEnabled = false
            editButton.isHidden = true
        }
        
        
        
    }
    
    func setLog(pointLog: PointLog) {
        residentLabel.text = pointLog.firstName + " " + pointLog.lastName
        pointTypeDescriptionLabel.text = pointLog.type.pointName
        descriptionLabel.text = pointLog.pointDescription
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateOccurred = pointLog.dateOccurred!.dateValue()
        dateOccurredLabel.text = dateFormatter.string(from: dateOccurred)
        let dateSubmitted = pointLog.dateSubmitted!.dateValue()
        dateSubmittedLabel.text = dateFormatter.string(from: dateSubmitted)
    }
    
    @IBAction func editPointType(_ sender: Any) {
        delegate?.goToNextScene()
    }
    
    
}
