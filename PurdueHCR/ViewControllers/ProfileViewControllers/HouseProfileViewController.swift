//
//  SecondViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/23/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import FirebaseAuth
import Cely
import PopupKit

class HouseProfileViewController: UIViewController, UIScrollViewDelegate, CustomViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet var profileView: ProfileView!
	@IBOutlet weak var housePointsCompareView: HousePointsCompareView!
	@IBOutlet weak var housePointsView: HousePointsView!
	@IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var topScorersView: UITableView!
    
    
    var refresher: UIRefreshControl?
    var refreshCount = 0
	var p : PopupView?
	var house : House?
    let radius : CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
	
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.refreshControl = refresher
		
        self.profileView.layer.shadowColor = UIColor.darkGray.cgColor
        self.profileView.layer.shadowOpacity = 0.5
        self.profileView.layer.shadowOffset = CGSize.zero
        self.profileView.layer.shadowRadius = 5
        self.profileView.layer.cornerRadius = radius
		self.profileView.delegate = self
		
        self.housePointsView.layer.shadowColor = UIColor.darkGray.cgColor
        self.housePointsView.layer.shadowOpacity = 0.5
        self.housePointsView.layer.shadowOffset = CGSize.zero
        self.housePointsView.layer.shadowRadius = 5
		self.housePointsView.layer.cornerRadius = radius
		self.housePointsView.sizeToFit()
        
        self.housePointsCompareView.layer.shadowColor = UIColor.black.cgColor
        self.housePointsCompareView.layer.shadowOpacity = 0.5
        self.housePointsCompareView.layer.shadowOffset = CGSize.zero
        self.housePointsCompareView.layer.shadowRadius = 5
		self.housePointsCompareView.layer.cornerRadius = radius
        
        
		let permission = User.get(.permissionLevel) as! Int
		if (permission != 0 && permission != 1) {
			self.navigationItem.rightBarButtonItems = nil
		}
        if (permission == 3) {
            // Set up the top scorer's view for FHPs
            let cell = topScorersView.dequeueReusableCell(withIdentifier: "top_scorer_cell")
            cell.activeView.layer.cornerRadius = cell.activeView.frame.width / 2
        } else {
            topScorersView.isHidden = true
        }
		
		
		// TODO: A separate method should probably be created for this so that it doesn't have to pass around as much data but instead just returns a boolean whether or not the user has a notification
		
		if (self.navigationItem.rightBarButtonItems != nil) {
			DataManager.sharedManager.getMessagesForUser(onDone: { (pointLogs: [PointLog]) in
				if (pointLogs.capacity > 0) {
					self.notificationsButton.setImage(#imageLiteral(resourceName: "BellNotification"), for: .normal)
				}
				else {
					self.notificationsButton.setImage(#imageLiteral(resourceName: "Bell"), for: .normal)
				}
			})
		}
		
		var sysPref : SystemPreferences?
		DataManager.sharedManager.refreshSystemPreferences { (systemPreferences) in
			sysPref = systemPreferences
			// Error checking here
			let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
			if (sysPref?.iosVersion != appVersion) {
				let alertController = UIAlertController.init(title: "Update Available", message: "It looks like you do not have the newest version of PurdueHCR. Please update as soon as posible to ensure you get all the latest and greatest features!", preferredStyle: .alert)
				let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: .none)
				alertController.addAction(okAction)
				self.present(alertController, animated: true, completion: .none)
			}
		}
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		refreshData()
	}
	
    @objc func refreshData(){
		refreshCount = 0
        DataManager.sharedManager.refreshUser(onDone: {(err:Error?) in
            self.profileView.reloadData()
            self.handleRefresher()
        })
        DataManager.sharedManager.refreshHouses(onDone: {(hs:[House]) in
            self.housePointsView.refresh()
            self.housePointsCompareView.refreshDataSet()
            self.handleRefresher()
        })
		if (navigationItem.rightBarButtonItems != nil) {
			DataManager.sharedManager.getMessagesForUser(onDone: { (pointLogs: [PointLog]) in
				if (pointLogs.capacity > 0) {
					self.notificationsButton.setImage(#imageLiteral(resourceName: "BellNotification"), for: .normal)
				}
				else {
					self.notificationsButton.setImage(#imageLiteral(resourceName: "Bell"), for: .normal)
				}
			})
		}
    }
    
    func handleRefresher(){
        refreshCount = refreshCount + 1
        if(refreshCount == 2){
            self.refresher?.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segueToProfilePointView() {
        self.performSegue(withIdentifier: "My_Points", sender: self)
    }
	
	@IBAction func showSettings(_ sender: Any) {

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
        let yPos = self.view.frame.height - ((self.tabBarController?.view!.safeAreaInsets.bottom)!) - (CGFloat(height) / 2) - 10
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: (self.tabBarController?.view)!)
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
			try? Auth.auth().signOut()
			Cely.logout()
		}
		
		alert.addAction(noAction)
		alert.addAction(yesAction)
		
		self.present(alert, animated: true)
	}
	
	@objc func reportBug(sender: UIButton!) {
		UIApplication.shared.open(URL(string: "https://sites.google.com/view/hcr-points/home")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
	}
	
	func goToNextScene() {
		let storyboard = UIStoryboard(name: "Profile", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "UserPointsController")
		vc.title = "Submitted Points"
		self.navigationController?.pushViewController(vc, animated: true)
	}
		
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}


