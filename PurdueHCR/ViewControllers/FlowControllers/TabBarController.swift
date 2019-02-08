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
			//viewControllers.append(linkSettingsViewController())
        }
        else if( p == 1){
            //RHP Controllers
            viewControllers.append(linkProfileViewController())
            viewControllers.append(linkPointSubmissionViewController())
            viewControllers.append(linkPointApprovalViewController())
            viewControllers.append(linkQRCodeViewController())
			viewControllers.append(linkSettingsViewController())

        }
        else if( p == 2){
            //REA/REC Controllers
            viewControllers.append(linkRECHouseViewController())
            viewControllers.append(linkQRCodeViewController())
            viewControllers.append(linkRECPointOptionsViewController())
            viewControllers.append(linkRECRewardsViewController())
			viewControllers.append(linkSettingsViewController())

        }
        // Do any additional setup after loading the view.
        self.setViewControllers(viewControllers, animated: false)
		let button = UIButton.init(type: .custom)
		button.frame = CGRect(x: self.tabBar.center.x + 140, y: self.view.bounds.height - 75, width: 25, height: 25)
		button.layer.cornerRadius = 32
		//button.backgroundColor = UIColor.cyan
		button.addTarget(self, action: #selector(showLogout), for: .touchUpInside)
		button.setBackgroundImage(#imageLiteral(resourceName: "Settings"), for: .normal)
		self.view.insertSubview(button, aboveSubview: self.tabBar)
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
		pointApprovalViewController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "check"), selectedImage: #imageLiteral(resourceName: "check"))
		//pointApprovalViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        return pointApprovalViewController
		// Name was Approve
    }
    
    func linkQRCodeViewController() -> UIViewController {
        let qrCodeViewController = UIStoryboard(name: "QRCode", bundle: nil).instantiateViewController(withIdentifier: "QR_Code_Initial") as! UINavigationController
        qrCodeViewController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "QRCode"), selectedImage: #imageLiteral(resourceName: "QRCode"))
		//qrCodeViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
		return qrCodeViewController
		// Name was QR
    }
    
    func linkRECHouseViewController() -> UIViewController {
        let recHouseViewController = UIStoryboard(name: "RECHouse", bundle: nil).instantiateViewController(withIdentifier: "HouseOverview") as! UINavigationController
        recHouseViewController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "Competition"), selectedImage: #imageLiteral(resourceName: "Competition"))
		//recHouseViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
		return recHouseViewController
		// Name was Houses
    }
    
    func linkRECPointOptionsViewController() -> UIViewController {
        let pointOptionsViewController = UIStoryboard(name: "RECPointOptions", bundle: nil).instantiateViewController(withIdentifier: "PointOptions") as! UINavigationController
        pointOptionsViewController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list"))
		//pointOptionsViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
		return pointOptionsViewController
		// Name was Points
    }
    
    func linkRECRewardsViewController() -> UIViewController {
        let rewardsViewController = UIStoryboard(name: "RECRewards", bundle: nil).instantiateViewController(withIdentifier: "Rewards") as! UINavigationController
        rewardsViewController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "RewardIcon"), selectedImage: #imageLiteral(resourceName: "RewardIcon"))
		//rewardsViewController.tabBarItem.imageInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
		return rewardsViewController
		// Title was Rewards
    }
	
	func linkSettingsViewController() -> UIViewController {
		let vc = UIViewController.init()
		return vc
	}
	
	@objc func showLogout(sender: UIButton!) {
		let color = UIColor.lightGray
		
		let width : Int = Int(self.view.frame.width - 20)
		let height = 280
		let distance = 20
		let buttonWidth = width - (distance * 2)
		let borderWidth : CGFloat = 2
		
		let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
		contentView.backgroundColor = UIColor.white
		contentView.layer.cornerRadius = radius
		
		p = PopupView.init(contentView: contentView)
		p?.maskType = .dimmed
		p?.layer.cornerRadius = radius
		
		let reportButton = UIButton.init(frame: CGRect.init(x: distance, y: 115, width: buttonWidth, height: 75))
		reportButton.layer.cornerRadius = radius
		reportButton.layer.borderWidth = borderWidth
		reportButton.layer.borderColor = color.cgColor
		reportButton.setTitleColor(UIColor.black, for: .normal)
		reportButton.setTitle("Report a bug", for: .normal)
		reportButton.addTarget(self, action: #selector(reportBug), for: .touchUpInside)
		
		let logoutButton = UIButton.init(frame: CGRect.init(x: distance, y: 25, width: buttonWidth, height: 75))
		logoutButton.layer.cornerRadius = radius
		logoutButton.layer.borderWidth = borderWidth
		logoutButton.layer.borderColor = color.cgColor
		logoutButton.setTitleColor(UIColor.black, for: .normal)
		logoutButton.setTitle("Logout", for: .normal)
		logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
		
		let closeButton = UIButton.init(frame: CGRect.init(x: width/2 - 45, y: height - 75, width: 90, height: 50))
		closeButton.layer.cornerRadius = 25
		closeButton.setTitle("Cancel", for: .normal)
		closeButton.backgroundColor = color
		closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
		
		contentView.addSubview(reportButton)
		contentView.addSubview(logoutButton)
		contentView.addSubview(closeButton)
		
		let xPos = self.view.frame.width / 2
		let yPos : CGFloat = self.view.frame.height - self.view.safeAreaInsets.bottom - (CGFloat(height) / 2) - 10
		let location = CGPoint.init(x: xPos, y: yPos)
		p?.showType = .slideInFromBottom
		p?.maskType = .dimmed
		p?.dismissType = .slideOutToBottom
		//p?.show(at: location, in: (self.tabBarController?.view)!)
		p?.show(at: location, in: self.view)
	}
	
	@objc func buttonAction(sender: UIButton!) {
		p?.dismissType = .slideOutToBottom
		p?.dismiss(animated: true)
	}
	
	@objc func logout(sender: UIButton!) {
		let alert = UIAlertController.init(title: "Log out?", message: "Are you sure you want to log out?", preferredStyle: .alert)
		
		let noAction = UIAlertAction.init(title: "No", style: .default) { (action) in
		}
		let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
			//try? Auth.auth().signOut()
			//Cely.logout()
		}
		
		alert.addAction(noAction)
		alert.addAction(yesAction)
		
		self.present(alert, animated: true)
	}
	
	@objc func reportBug(sender: UIButton!) {
		//UIApplication.shared.open(URL(string: "https://sites.google.com/view/hcr-points/home")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
	}
	
//    override func viewWillAppear(_ animated: Bool) {
//        if(NewLaunch.newLaunch.isFirstLaunch){
//            createNewLaunchAlert()
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
