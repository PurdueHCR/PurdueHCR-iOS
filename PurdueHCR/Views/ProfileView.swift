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
	
    @IBOutlet weak var colorBanner: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var totalPointsLabel: UILabel!
	@IBOutlet weak var viewPointsButton: UIButton!
    @IBOutlet weak var rankNumberLabel: UILabel!
    @IBOutlet weak var rankHeaderLabel: UILabel!
    @IBOutlet weak var houseEmblem: UIButton!
    
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
		
        let permissionLevel = PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)
		if (permissionLevel == PointType.PermissionLevel.fhp) {
			viewPointsButton.isEnabled = false
			viewPointsButton.isHidden = true
			totalPointsLabel.text = ""
		}
        houseEmblem.backgroundColor = UIColor.white
        houseEmblem.layer.cornerRadius = houseEmblem.frame.height / 2
        var houseImage: UIImage!
        let houseName = User.get(.house) as! String
       
        if(houseName == "Platinum"){
            houseImage = UIImage.init(imageLiteralResourceName: "Platinum").withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        else if(houseName == "Copper"){
            houseImage = UIImage.init(imageLiteralResourceName: "Copper").withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        else if(houseName == "Palladium"){
            houseImage = UIImage.init(imageLiteralResourceName: "Palladium").withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        else if(houseName == "Silver"){
            houseImage = UIImage.init(imageLiteralResourceName: "Silver").withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        else if(houseName == "Titanium"){
            houseImage = UIImage.init(imageLiteralResourceName: "Titanium").withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        houseEmblem.setImage(houseImage, for: .normal)
        houseEmblem.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        houseEmblem.isEnabled = true;
        houseEmblem.imageView?.alpha = 1.0;
    
        var houses = DataManager.sharedManager.getHouses()!
        let house = houses.remove(at: houses.firstIndex(of: House(id: houseName, points: 0, hexColor:""))!)
        colorBanner.backgroundColor = AppUtils.hexStringToUIColor(hex: house.hexColor)
        
        houseEmblem.layer.borderColor = colorBanner.backgroundColor?.cgColor
        houseEmblem.layer.borderWidth = 4
        colorBanner.layer.cornerRadius = DefinedValues.radius
        colorBanner.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.reloadData();
        
        if (User.get(.permissionLevel)
           as! Int == 1){
         self.rankHeaderLabel.text = "";
         self.rankNumberLabel.text = "";
         
        }
        else{
            DataManager.sharedManager.getHouseRank(residentID: User.get(.id) as! String, house: User.get(.house) as! String) { (houseRank) in
                 self.rankNumberLabel.text = "#" + houseRank.description
             
            }
        }
    }
    
    func reloadData() {
        
        totalPointsLabel.adjustsFontSizeToFitWidth = true
        totalPointsLabel.text = (User.get(.points) as! Int).description
		
        totalPointsLabel.accessibilityIdentifier = "Resident Points"
        
        
    }
	
    @IBAction func transition(_ sender: Any) {
        transitionFunc()
    }
	
	@IBAction func viewUserPoints(_ sender: Any) {
		delegate?.goToNextScene()
	}
	
}
