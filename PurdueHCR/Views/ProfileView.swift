//
//  ProfileView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/15/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class ProfileView: UIView {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet var houseLogoImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var totalPointsLabel: UILabel!
    //@IBOutlet var achievementLabel: UILabel!
    @IBOutlet var pointsButton: UILabel! // change back to button for the Medals update
    
    
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
        pointsButton.text = "Stay tuned for:\n The Medals Update!"
        pointsButton.layer.borderWidth = 2.0
        pointsButton.layer.borderColor = UIColor.black.cgColor
        totalPointsLabel.layer.borderWidth = 2.0
        totalPointsLabel.layer.borderColor = UIColor.black.cgColor
        reloadData()
    }
    
    func reloadData(){
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
        nameLabel.text = "Welcome\n" + (User.get(.name) as! String)
        totalPointsLabel.text = (User.get(.points) as! Int).description + "\npoints"
        
    }
    
    @IBAction func transition(_ sender: Any) {
        transitionFunc()
    }
    
}
