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
        self.house = houses.remove(at: houses.index(of: House(id: User.get(.house) as! String, points: 0,hexColor:""))!)
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder){
        var houses = DataManager.sharedManager.getHouses()!
        self.rewards = DataManager.sharedManager.getRewards()!
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
        
        circleProgress.progressColors = [AppUtils.hexStringToUIColor(hex: house.hexColor),UIColor.white]
        let reward = getCurrentReward()
        if(reward != nil){
            nextRewardLabel.text = "Next Reward:\n"+reward!.rewardName
            rewardImageView = createImageView()
            rewardImageView?.center = self.circleProgress.convert(self.circleProgress.center, from:self.circleProgress)
            rewardImageView?.image = reward!.image
            circleProgress.angle = (Double(self.house.totalPoints) / Double(reward!.requiredValue)) * 360.0
            pointsRemainingLabel.text? = "Next Goal: " + self.house.totalPoints.description + "/"+reward!.requiredValue.description
            addSubview(rewardImageView!)
        }
        else{
            circleProgress.angle = 180.0
            pointsRemainingLabel.text? = "Next Goal: Victory"
        }
    }
    
    func createImageView() -> UIImageView {
        if(rewardImageView == nil){
            let size = self.circleProgress.frame.size.width * 0.6
            let corner = self.circleProgress.center
            return UIImageView(frame: CGRect(x: corner.x , y: corner.y, width: size, height: size))
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
