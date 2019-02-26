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
    @IBOutlet var nextRewardLabel: UILabel!
    
    @IBOutlet var backgroundView: UIView!
    
    var rewardImageView: UIImageView?
    
    var house: House
    var rewards: [Reward]
    
    override init(frame: CGRect){
        var houses = DataManager.sharedManager.getHouses()!
        self.rewards = DataManager.sharedManager.getRewards()!
        self.house = houses.remove(at: houses.index(of: House(id: User.get(.house) as! String, points: 0,hexColor:"",numberOfResidents: 0))!)
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder){
        var houses = DataManager.sharedManager.getHouses()!
        self.rewards = DataManager.sharedManager.getRewards()!
        self.house = houses.remove(at: houses.index(of: House(id: User.get(.house) as! String, points: 0, hexColor:"",numberOfResidents: 0))!)
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("HousePointsView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundView.layer.cornerRadius = 10
        
        rewardImageView = createImageView()
    }
    
    func refresh(){
        var houses = DataManager.sharedManager.getHouses()!
        self.house = houses.remove(at: houses.index(of: House(id: User.get(.house) as! String, points: 0,hexColor:"",numberOfResidents: 0))!)
        
        circleProgress.progressColors = [AppUtils.hexStringToUIColor(hex: house.hexColor),UIColor.white]
		//circleProgress.glowMode = KDCircularProgressGlowMode.noGlow
        rewardImageView?.center = self.circleProgress.convert(self.circleProgress.center, from:self.circleProgress)
        let reward = getCurrentReward()
        if(reward != nil){
            nextRewardLabel.text = "Next Reward:\n"+reward!.rewardName
            rewardImageView?.image = reward!.image
            circleProgress.angle = (Double(self.house.totalPoints) / Double(reward!.requiredValue)) * 360.0
            pointsRemainingLabel.text? = "Next Goal: " + self.house.totalPoints.description + "/"+reward!.requiredValue.description
        }
        else{
            nextRewardLabel.text = "Next Reward:\n Eternal Glory"
            rewardImageView?.image = nil
            circleProgress.angle = 180.0
            pointsRemainingLabel.text? = "Next Goal: Victory"
        }
        
        rewardImageView?.center = self.circleProgress.convert(self.circleProgress.center, from:self.circleProgress)
        addSubview(rewardImageView!)
    }
    
    func createImageView() -> UIImageView {
        if(rewardImageView == nil){
            let size = self.circleProgress.frame.size.width * 0.4
            return UIImageView(frame: CGRect(x:0, y: 1000, width: size, height: size))
        }
        else{
            return rewardImageView!
        }
        
    }
    
    func getCurrentReward() -> Reward?{
        var i = 0
        while( i < rewards.count){
            if(rewards[i].requiredValue > self.house.totalPoints){
                return rewards[i]
            }
            i += 1
        }
        return nil
    }
}
