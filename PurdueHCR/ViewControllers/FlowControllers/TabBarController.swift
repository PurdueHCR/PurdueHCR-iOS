//
//  TabBarController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import PopupKit

class TabBarController: UITabBarController {

	//var topInset : CGFloat = 20
	//var bottomInset : CGFloat = 5
	var p : PopupView?
	let radius : CGFloat = 10
	
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let permission = User.get(.permissionLevel) else{
            return
        }
        let p = permission as! Int
        var viewControllers : [UIViewController] = []
        if (p == 0){
            //Resident Controllers
            viewControllers.append(linkProfileViewController())
            viewControllers.append(linkPointSubmissionViewController())
        }
        else if( p == 1){
            //RHP Controllers
            viewControllers.append(linkProfileViewController())
            viewControllers.append(linkPointSubmissionViewController())
            viewControllers.append(linkPointApprovalViewController())
            viewControllers.append(linkQRCodeViewController())

        }
        else if( p == 2){
            //REA/REC Controllers
            viewControllers.append(linkRECHouseViewController())
            viewControllers.append(linkQRCodeViewController())
            viewControllers.append(linkRECPointOptionsViewController())
            viewControllers.append(linkRECRewardsViewController())

        }
        // Do any additional setup after loading the view.
        self.setViewControllers(viewControllers, animated: false)
    }
    
    func linkPointSubmissionViewController() -> UIViewController {
        let pointSubmissionViewController = UIStoryboard(name: "PointSubmission", bundle: nil).instantiateViewController(withIdentifier: "Point_Submission_Initial") as! UINavigationController
		//pointSubmissionViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        return pointSubmissionViewController
    }
    
    func linkProfileViewController() -> UIViewController {
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "Profile_Initial") as! UINavigationController
		//profileViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        return profileViewController
    }
    
    func linkPointApprovalViewController() -> UIViewController {
        let pointApprovalViewController = UIStoryboard(name: "PointApproval", bundle: nil).instantiateViewController(withIdentifier: "Point_Approval_Initial") as! UINavigationController
		pointApprovalViewController.tabBarItem = UITabBarItem(title: "Approve", image: #imageLiteral(resourceName: "check"), selectedImage: #imageLiteral(resourceName: "check"))
		//pointApprovalViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        return pointApprovalViewController
    }
    
    func linkQRCodeViewController() -> UIViewController {
        let qrCodeViewController = UIStoryboard(name: "QRCode", bundle: nil).instantiateViewController(withIdentifier: "QR_Code_Initial") as! UINavigationController
        qrCodeViewController.tabBarItem = UITabBarItem(title: "QR", image: #imageLiteral(resourceName: "QRCode"), selectedImage: #imageLiteral(resourceName: "QRCode"))
		//qrCodeViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
		return qrCodeViewController
    }
    
    func linkRECHouseViewController() -> UIViewController {
        let recHouseViewController = UIStoryboard(name: "RECHouse", bundle: nil).instantiateViewController(withIdentifier: "HouseOverview") as! UINavigationController
        recHouseViewController.tabBarItem = UITabBarItem(title: "Houses", image: #imageLiteral(resourceName: "Competition"), selectedImage: #imageLiteral(resourceName: "Competition"))
		//recHouseViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
		return recHouseViewController
    }
    
    func linkRECPointOptionsViewController() -> UIViewController {
        let pointOptionsViewController = UIStoryboard(name: "RECPointOptions", bundle: nil).instantiateViewController(withIdentifier: "PointOptions") as! UINavigationController
        pointOptionsViewController.tabBarItem = UITabBarItem(title: "Points", image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list"))
		//pointOptionsViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
		return pointOptionsViewController
    }
    
    func linkRECRewardsViewController() -> UIViewController {
        let rewardsViewController = UIStoryboard(name: "RECRewards", bundle: nil).instantiateViewController(withIdentifier: "Rewards") as! UINavigationController
        rewardsViewController.tabBarItem = UITabBarItem(title: "Rewards", image: #imageLiteral(resourceName: "RewardIcon"), selectedImage: #imageLiteral(resourceName: "RewardIcon"))
		//rewardsViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
		return rewardsViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
