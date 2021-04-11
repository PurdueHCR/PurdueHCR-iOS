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
    @IBOutlet weak var houseEmblem: UIButton!
    @IBOutlet weak var houseNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!

    // For when only year rank visible
    @IBOutlet weak var rankHeaderLabel: UILabel!
    @IBOutlet weak var yearRankLabel: UILabel!
    @IBOutlet weak var yearRankView: UIView!
    
    // For when both ranks are visible
    @IBOutlet weak var bothRankView: UIView!
    @IBOutlet weak var semesterRankBoth: UILabel!
    @IBOutlet weak var yearRankBoth: UILabel!
    
    // For when only semester rank visible
    @IBOutlet weak var semesterRankView: UIView!
    @IBOutlet weak var semesterRankOnlyLabel: UILabel!
    
    var rankViewIndex = 0
    
    var p : PopupView?
	
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.switchRankViews(_:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.switchRankViews(_:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.switchRankViews(_:)))
        bothRankView.addGestureRecognizer(tap)
        semesterRankView.addGestureRecognizer(tap2)
        yearRankView.addGestureRecognizer(tap3)

        let defaults = UserDefaults.standard
        if let layoutIndex = defaults.object(forKey: "rank_layout_index") {
            rankViewIndex = layoutIndex as! Int
        } else {
            defaults.setValue(rankViewIndex, forKey: "rank_layout_index")
        }
        layoutRankViews()
		
        viewPointsButton.layer.cornerRadius = viewPointsButton.layer.frame.height / 2
		
        infoButton.isHidden = true
        blackButton.isHidden = true
        blackButton.layer.cornerRadius = infoButton.layer.frame.height / 2
        
        let permissionLevel = PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)
		if (permissionLevel == PointType.PermissionLevel.faculty) {
			viewPointsButton.isEnabled = false
			viewPointsButton.isHidden = true
			totalPointsLabel.text = ""
		}
        if (permissionLevel == PointType.PermissionLevel.rhp) {
            infoButton.isHidden = false
            blackButton.isHidden = false
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
        houseEmblem.isEnabled = true
        houseEmblem.imageView?.alpha = 1.0
        
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
                    let yearRank = "" + houseRank!.description
                    let semesterRank = "" + semesterRank!.description
                    self.yearRankLabel.text = yearRank
                    self.yearRankBoth.text = yearRank
                    self.semesterRankBoth.text = semesterRank
                    self.semesterRankOnlyLabel.text = semesterRank
                }
            }
            
        } else {
            self.yearRankLabel.text = "🙈"
            self.yearRankBoth.text = "🙈"
            self.semesterRankBoth.text = "🙈"
            self.semesterRankOnlyLabel.text = "🙈"
        }
    }
    
    func reloadData() {
        
        totalPointsLabel.adjustsFontSizeToFitWidth = true
        totalPointsLabel.text = (User.get(.points) as! Int).description
        totalPointsLabel.accessibilityIdentifier = "Resident Points"
        
    }
    
    // Setup which rank view is visible
    func layoutRankViews() {
        let defaults = UserDefaults.standard
        switch (rankViewIndex) {
        case 0:
            semesterRankView.isHidden = false
            yearRankView.isHidden = true
            bothRankView.isHidden = true
            defaults.setValue(rankViewIndex, forKey: "rank_layout_index")
            rankViewIndex = 1
            break
        case 1:
            semesterRankView.isHidden = true
            yearRankView.isHidden = false
            bothRankView.isHidden = true
            defaults.setValue(rankViewIndex, forKey: "rank_layout_index")
            rankViewIndex = 2
            break
        case 2:
            semesterRankView.isHidden = true
            yearRankView.isHidden = true
            bothRankView.isHidden = false
            defaults.setValue(rankViewIndex, forKey: "rank_layout_index")
            rankViewIndex = 0
            break
        default:
            break
        }
    }
    
    @objc func switchRankViews(_ sender: UITapGestureRecognizer? = nil) {
        layoutRankViews()
    }
    
    @IBAction func showHouseCodes(_ sender: Any) {
        guard let del = self.delegate else { return }
        let parent = del as! HouseProfileViewController
        let width : Int = Int(parent.view.frame.width - 70)

        let contentView = UIView()
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = DefinedValues.radius
        
        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        p?.layer.cornerRadius = DefinedValues.radius
        
        var lastPosition = 25
        let codesTitle = UILabel(frame: CGRect(x: 0, y: lastPosition, width: width, height: 20))
        codesTitle.text = "HOUSE CODES"
        codesTitle.font = .systemFont(ofSize: 21, weight: .medium)
        codesTitle.textColor = UIColor.darkGray
        codesTitle.textAlignment = .center
        
        lastPosition += 35
        
        let codes = DataManager.sharedManager.getHouseCodes()!
        for code in codes {
            if (code.house == User.get(.house) as! String) {
                if (!code.codeName.contains("RHP")) {
                    lastPosition += 5
                    // Displays name of code
                    let codeTitle = UITextView(frame: CGRect(x: 15, y: lastPosition, width: width - 95 - 15, height: 30))
                    codeTitle.isScrollEnabled = false
                    codeTitle.isEditable = false
                    codeTitle.text = code.codeName + ":"
                    codeTitle.font = .systemFont(ofSize: 17, weight: .regular)
                    codeTitle.textAlignment = .right
                    
                    // Displays actual code value
                    let codeValue = UITextView(frame: CGRect(x: width - 95, y: lastPosition, width: 80, height: 30))
                    codeValue.isScrollEnabled = false
                    codeValue.isEditable = false
                    codeValue.text = code.code
                    codeValue.font = .systemFont(ofSize: 17, weight: .regular)
                    codeValue.textAlignment = .right
                    
                    lastPosition += 30
                    contentView.addSubview(codeTitle)
                    contentView.addSubview(codeValue)
                }
            }
        }
        
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: lastPosition + 25)
        
        let closeButton = UIButton(frame: CGRect(x: width - 35, y: 10, width: 25, height: 25))
        let closeImage = #imageLiteral(resourceName: "SF_xmark").withRenderingMode(.alwaysTemplate)
        closeButton.setBackgroundImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.lightGray
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
