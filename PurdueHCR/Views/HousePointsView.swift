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
	@IBOutlet weak var pointsTotalLabel: UILabel!
	@IBOutlet var nextRewardLabel: UILabel!
    
    @IBOutlet var backgroundView: UIView!
    
    var rewardImageView: UIImageView?
    
    var house: House
    var rewards: [Reward]
    
    override init(frame: CGRect){
        var houses = DataManager.sharedManager.getHouses()!
        self.rewards = DataManager.sharedManager.getRewards()!
        self.house = houses.remove(at: houses.firstIndex(of: House(id: User.get(.house) as! String, points: 0, hexColor:""))!)
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        var houses = DataManager.sharedManager.getHouses()!
        self.rewards = DataManager.sharedManager.getRewards()!
        self.house = houses.remove(at: houses.firstIndex(of: House(id: User.get(.house) as! String, points: 0, hexColor:""))!)
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
        pointsRemainingLabel.accessibilityIdentifier = "TotalHousePoints"
    }
    
    func refresh(){
        var houses = DataManager.sharedManager.getHouses()!
        self.house = houses.remove(at: houses.firstIndex(of: House(id: User.get(.house) as! String, points: 0,hexColor:""))!)
        
        circleProgress.progressColors = [AppUtils.hexStringToUIColor(hex: house.hexColor),UIColor.white]
        let reward = getCurrentReward()
		let prevRewardValue = getPrevRewardValue()
		print("Previous reward value: ", prevRewardValue)
        if(reward != nil){
			nextRewardLabel.text = reward!.rewardName
            rewardImageView?.image = reward!.image
            circleProgress.angle = (Double(self.house.totalPoints - prevRewardValue) / Double(reward!.requiredPPR - prevRewardValue)) * 360.0
            var pointsToGo = Double(reward!.requiredPPR) - (Double(self.house.totalPoints) / Double(self.house.numResidents))
            // Round to two decimal places
            pointsToGo = Double(round(100*pointsToGo)/100)
			pointsRemainingLabel.text? = pointsToGo.description
            // Required PPR will always be an integer so we can add the zeros on the end without worrying about converting to a double and then rounding to two decimals
            pointsTotalLabel.text = "(" + reward!.requiredPPR.description + ".00 total)"
        }
        else{
            nextRewardLabel.text = "Eternal Glory"
            rewardImageView?.image = nil
            circleProgress.angle = 180.0
            pointsRemainingLabel.text? = "Victory"
        }
        
        rewardImageView?.center = self.circleProgress.convert(self.circleProgress.center, from: self.circleProgress)
        addSubview(rewardImageView!)
    }
    
    func createImageView() -> UIImageView {
        if(rewardImageView == nil){
			// TODO: Fix this mess please :)
            let size = self.circleProgress.frame.size.width * 0.28
            return UIImageView(frame: CGRect(x: self.circleProgress.center.x - size/2, y: self.circleProgress.center.y - size/2, width: size, height: size))
        }
        else{
            return rewardImageView!
        }
        
    }
    
    func getCurrentReward() -> Reward?{
        var i = 0
        while( i < rewards.count){
            if(rewards[i].requiredPPR > (self.house.totalPoints / self.house.numResidents)){
                return rewards[i]
            }
            i += 1
        }
        return nil
    }
	
	func getPrevRewardValue() -> Int {
		var i = 0
		while( i < rewards.count){
			if (rewards[i].requiredPPR > (self.house.totalPoints / self.house.numResidents)){
				if (i > 0) {
					return rewards[i - 1].requiredPPR
				}
				return 0;
			}
			i += 1
		}
		return 0
	}
}
