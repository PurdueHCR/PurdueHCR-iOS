//
//  TopScorersView.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/6/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

class TopScorersView: UIView {

    @IBOutlet var topScorersView: UIView!
    @IBOutlet weak var first: UILabel!
    @IBOutlet weak var second: UILabel!
    @IBOutlet weak var third: UILabel!
    @IBOutlet weak var fourth: UILabel!
    @IBOutlet weak var fifth: UILabel!
    @IBOutlet weak var colorView: UIButton!
    @IBOutlet weak var firstScore: UILabel!
    @IBOutlet weak var secondScore: UILabel!
    @IBOutlet weak var thirdScore: UILabel!
    @IBOutlet weak var fourthScore: UILabel!
    @IBOutlet weak var fifthScore: UILabel!
    
    var testText = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("TopScorersView", owner: self, options: nil)
        addSubview(topScorersView)
        topScorersView.frame = self.bounds
        topScorersView.layer.cornerRadius = DefinedValues.radius
        
        var houses = DataManager.sharedManager.getHouses()!
        let house = houses.remove(at: houses.firstIndex(of: House(id: User.get(.house) as! String, points: 0, hexColor:""))!)
        colorView.backgroundColor = AppUtils.hexStringToUIColor(hex: house.hexColor)
        colorView.layer.cornerRadius = DefinedValues.radius
        colorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        DataManager.sharedManager.getHouseScorers {
            let house = self.getHouseWithName(name: User.get(.house) as! String)
            self.first.text = house?.topScoreUsers?[0].userName
            self.firstScore.text = house?.topScoreUsers?[0].totalPoints.description
            self.second.text = house?.topScoreUsers?[1].userName
            self.secondScore.text = house?.topScoreUsers?[1].totalPoints.description
            self.third.text = house?.topScoreUsers?[2].userName
            self.thirdScore.text = house?.topScoreUsers?[2].totalPoints.description
            self.fourth.text = house?.topScoreUsers?[3].userName
            self.fourthScore.text = house?.topScoreUsers?[3].totalPoints.description
            self.fifth.text = house?.topScoreUsers?[4].userName
            self.fifthScore.text = house?.topScoreUsers?[4].totalPoints.description
       }
        
        topScorersView.sizeToFit()
    }
    
    // TODO: This function and it's counterpart in the REC controllers
    //       should probably be moved to the DataManager
    func getHouseWithName(name:String) -> House?{
        for house in DataManager.sharedManager.getHouses()!{
            if house.houseID == name{
                return house
            }
        }
        return nil
    }
    
}
