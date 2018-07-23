//
//  HousePointsView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import KDCircularProgress

class HousePointsView: UIView {

    @IBOutlet var circleProgress: KDCircularProgress!
    @IBOutlet var pointsRemainingLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    
    var house: House
    
    override init(frame: CGRect){
        var houses = DataManager.sharedManager.getHouses()!
        self.house = houses.remove(at: houses.index(of: House(id: User.get(.house) as! String, points: 0,hexColor:""))!)
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder){
        var houses = DataManager.sharedManager.getHouses()!
        self.house = houses.remove(at: houses.index(of: House(id: User.get(.house) as! String, points: 0, hexColor:""))!)
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("HousePointsView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        refresh()
    }
    func refresh(){
        var houses = DataManager.sharedManager.getHouses()!
        self.house = houses.remove(at: houses.index(of: House(id: User.get(.house) as! String, points: 0,hexColor:""))!)
        circleProgress.angle = (Double(self.house.totalPoints) / 1000.0) * 360.0
        circleProgress.progressColors = [UIColor.white,AppUtils.hexStringToUIColor(hex: house.hexColor)]
        pointsRemainingLabel.text? = "Next Goal: " + self.house.totalPoints.description + "/1000"
    }
}
