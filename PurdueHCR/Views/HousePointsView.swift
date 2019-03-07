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
        rewardImageView?.center = self.circleProgress.convert(self.circleProgress.center, from: self.circleProgress)
        let reward = getCurrentReward()
		let prevRewardValue = getPrevRewardValue()
		print("Previous reward value: ", prevRewardValue)
        if(reward != nil){
            nextRewardLabel.text = "Next Reward:\n"+reward!.rewardName
            rewardImageView?.image = reward!.image
            circleProgress.angle = (Double(self.house.totalPoints - prevRewardValue) / Double(reward!.requiredValue - prevRewardValue)) * 360.0
			let pointsToGo = reward!.requiredValue - self.house.totalPoints
			pointsRemainingLabel.text? = (pointsToGo.description + " Points Away!")
        }
        else{
            nextRewardLabel.text = "Next Reward:\n Eternal Glory"
            rewardImageView?.image = nil
            circleProgress.angle = 180.0
            pointsRemainingLabel.text? = "Next Goal: Victory"
        }
        
        rewardImageView?.center = self.circleProgress.convert(self.circleProgress.center, from: self.circleProgress)
        addSubview(rewardImageView!)
    }
    
    func createImageView() -> UIImageView {
        if(rewardImageView == nil){
            var size = self.circleProgress.frame.size.width * 0.36
			//size = sqrt((size * size) * 2)
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
	
	func getPrevRewardValue() -> Int {
		var i = 0
		while( i < rewards.count){
			if(rewards[i].requiredValue > self.house.totalPoints){
				if (i > 0) {
					return rewards[i - 1].requiredValue
				}
				return 0;
			}
			i += 1
		}
		return 0
	}
}
