//
//  ProfileView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/15/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import PopupKit

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
    @IBOutlet weak var houseNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    
    var p : PopupView?
    
    //@IBOutlet var achievementLabel: UILabel!
//    @IBOutlet var pointsButton: UILabel! // change back to button for the Medals update
	
    var transitionFunc: () ->() = {print("NO IMPLEMENTATION")}
    var isCompetitionVisible: Bool = true
    
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
		
        infoButton.isHidden = true
        blackButton.layer.cornerRadius = 25
        
        let permissionLevel = PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)
		if (permissionLevel == PointType.PermissionLevel.faculty) {
			viewPointsButton.isEnabled = false
			viewPointsButton.isHidden = true
			totalPointsLabel.text = ""
		}
        if (permissionLevel == PointType.PermissionLevel.rhp) {
            infoButton.isHidden = false
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
        
        houseNameLabel.text = User.get(.house) as! String + " – " + (User.get(.floorID) as! String)
        self.reloadData();
        
        isCompetitionVisible = DataManager.sharedManager.systemPreferences!.isCompetitionVisible
        if (isCompetitionVisible) {
            DataManager.sharedManager.getHouseRank(residentID: User.get(.id) as! String, house: User.get(.house) as! String) { (houseRank, semesterRank, err) in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    self.rankNumberLabel.text = "#" + houseRank!.description
                }
            }
            
        } else {
            self.rankNumberLabel.text = "🙈"
        }
    }
    
    func reloadData() {
        
        totalPointsLabel.adjustsFontSizeToFitWidth = true
        totalPointsLabel.text = (User.get(.points) as! Int).description
		
        totalPointsLabel.accessibilityIdentifier = "Resident Points"
        
        
    }
    
    @IBAction func showHouseCodes(_ sender: Any) {
        guard let del = self.delegate else { return }
        let parent = del as! HouseProfileViewController
        //let color = UIColor.lightGray
        let width : Int = Int(parent.view.frame.width - 70)
        let height = 185
        //let distance = 20
        //let buttonWidth = width - (distance * 2)
        //let borderWidth : CGFloat = 2
        
        let contentView = UIView()
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = DefinedValues.radius
        
        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        p?.layer.cornerRadius = DefinedValues.radius
        
        var lastPosition = 25
        let codesTitle = UILabel(frame: CGRect(x: 0, y: lastPosition, width: width, height: 20))
        codesTitle.text = "HOUSE CODES"
        codesTitle.font = .systemFont(ofSize: 18, weight: .medium)
        codesTitle.textColor = UIColor.darkGray
        codesTitle.textAlignment = .center
        
        lastPosition += 35
        
        let codes = DataManager.sharedManager.getHouseCodes()!
        for code in codes {
            if (code.house == User.get(.house) as! String) {
                if (!code.codeName.contains("RHP")) {
                    lastPosition += 5
                    let codeName = UITextView(frame: CGRect(x: 20, y: lastPosition, width: width - 20, height: 30))
                    codeName.isScrollEnabled = false
                    codeName.isEditable = false
                    codeName.text = code.codeName + ": " + code.code
                    codeName.font = .systemFont(ofSize: 15, weight: .regular)
                    lastPosition += 30
                    contentView.addSubview(codeName)
                }
            }
        }
        
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: lastPosition + 25)
        
        let closeButton = UIButton(frame: CGRect(x: width - 35, y: 10, width: 25, height: 25))
        let closeImage = #imageLiteral(resourceName: "SF_xmark").withRenderingMode(.alwaysTemplate)
        closeButton.setBackgroundImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.darkGray
        closeButton.setTitle("", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissCodes), for: .touchUpInside)
        
        contentView.addSubview(codesTitle)
        contentView.addSubview(closeButton)
        
        let xPos = parent.view.frame.width / 2
        let yPos = parent.view.frame.height / 2 // - ((parent.tabBarController?.view!.safeAreaInsets.bottom)!) - (CGFloat(height) / 2) - 10
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: (parent.tabBarController?.view)!)
    }
    
    @objc func dismissCodes(sender: UIButton!) {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
    }
    
    @IBAction func transition(_ sender: Any) {
        transitionFunc()
    }
	
	@IBAction func viewUserPoints(_ sender: Any) {
		delegate?.goToNextScene()
	}
	
}
