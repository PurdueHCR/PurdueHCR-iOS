//
//  ProfileView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/15/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

protocol CustomViewDelegate: class {
	func goToNextScene()
}

class ProfileView: UIView {

	weak var delegate: CustomViewDelegate?
	
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var houseLogoImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var totalPointsLabel: UILabel!
	@IBOutlet weak var viewPointsButton: UIButton!
	//@IBOutlet var achievementLabel: UILabel!
//    @IBOutlet var pointsButton: UILabel! // change back to button for the Medals update
	
    var transitionFunc: () ->() = {print("NO IMPLEMENTATION")}
    
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		viewPointsButton.layer.cornerRadius = viewPointsButton.layer.frame.height / 2
		viewPointsButton.imageEdgeInsets = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
//        pointsButton.text = "Stay tuned for:\n The Medals Update!"
//        pointsButton.layer.borderWidth = 2.0
//        pointsButton.layer.borderColor = UIColor.black.cgColor
//        totalPointsLabel.layer.borderWidth = 0
//        totalPointsLabel.layer.borderColor = UIColor.black.cgColor
//		houseLogoImageView.frame(forAlignmentRect: CGRect.init(x: -100, y: 0, width: 25, height: 25))
		let permissionLevel = PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)
		if (permissionLevel == PointType.PermissionLevel.fhp) {
			viewPointsButton.isEnabled = false
			viewPointsButton.isHidden = true
			totalPointsLabel.text = ""
		}
        reloadData()
    }
    
    func reloadData() {
        let houseName = User.get(.house) as! String
        if(houseName == "Platinum"){
            houseLogoImageView.image = #imageLiteral(resourceName: "Platinum")
        }
        else if(houseName == "Copper"){
            houseLogoImageView.image = #imageLiteral(resourceName: "Copper")
        }
        else if(houseName == "Palladium"){
            houseLogoImageView.image = #imageLiteral(resourceName: "Palladium")
        }
        else if(houseName == "Silver"){
            houseLogoImageView.image = #imageLiteral(resourceName: "Silver")
        }
        else if(houseName == "Titanium"){
            houseLogoImageView.image = #imageLiteral(resourceName: "Titanium")
        }
		let firstName = User.get(.firstName) as! String
		let lastName = User.get(.lastName) as! String
        nameLabel.text = firstName + " " + lastName
		
		let permissionLevel = PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)
		if (permissionLevel == PointType.PermissionLevel.fhp) {
			totalPointsLabel.text = ""
		} else {
			totalPointsLabel.adjustsFontSizeToFitWidth = true
        	totalPointsLabel.text = (User.get(.points) as! Int).description + " points"
		}
		
        totalPointsLabel.accessibilityIdentifier = "Resident Points"
        
        
    }
	
    @IBAction func transition(_ sender: Any) {
        transitionFunc()
    }
	
	@IBAction func viewUserPoints(_ sender: Any) {
		delegate?.goToNextScene()
	}
	
}
