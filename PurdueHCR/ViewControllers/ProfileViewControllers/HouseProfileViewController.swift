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

// Custom view delegate allows for XIB views inside of the controller to
// use segues to other ViewControllers
class HouseProfileViewController: UITableViewController, CustomViewDelegate {
    
	@IBOutlet weak var settingsButton: UIBarButtonItem!
	@IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet var backgroundTable: UITableView!
    
    var refresher: UIRefreshControl?
    var refreshCount = 0
	var p : PopupView?
	var house : House?
    let padding : CGFloat = 12
    var permission: PointType.PermissionLevel?
   
    override func viewDidLoad() {
        super.viewDidLoad()
	
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        
        permission = PointType.PermissionLevel.init(rawValue: User.get(.permissionLevel) as! Int)!
        if (permission != PointType.PermissionLevel.resident && permission != PointType.PermissionLevel.rhp) {
			self.navigationItem.rightBarButtonItems = nil
		}
        if #available(iOS 13.0, *) {
            backgroundTable.backgroundColor = UIColor.systemGray5
        } else {
            backgroundTable.backgroundColor = DefinedValues.systemGray5
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
		
        
        refreshData()
    
    }
	
    // TODO: Fix refreshing of views
    @objc func refreshData(){
		refreshCount = 0
        DataManager.sharedManager.refreshUser(onDone: {(err:Error?) in
            //self.profileView.reloadData()
            self.handleRefresher()
        })
        DataManager.sharedManager.refreshHouses(onDone: {(hs:[House]) in
            //self.housePointsView.refresh()
            //self.housePointsCompareView.refreshDataSet()
           // self.topScorersView.refreshControl?.beginRefreshing()
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
        if (permission == PointType.PermissionLevel.fhp) {
            DataManager.sharedManager.getHouseScorers {
                self.house = self.getHouseWithName(name: User.get(.house) as! String)
                let path = IndexPath.init(row: 3, section: 0)
                self.tableView.reloadRows(at: [path], with: .none)
            }
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
		
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Set up the top scorer's view for FHPs
        //for user in (house?.topScoreUsers!)! {
        
        var cell : UITableViewCell!
        if (tableView.tag == 1) {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            for view in cell.subviews {
                view.removeFromSuperview()
            }
            
            switch indexPath.row {
            case 0:
                let profileView = ProfileView.init()
                profileView.layer.shadowColor = UIColor.darkGray.cgColor
                profileView.layer.shadowOpacity = 0.5
                profileView.layer.shadowOffset = CGSize.zero
                profileView.layer.shadowRadius = 5
                profileView.layer.cornerRadius = DefinedValues.radius
                profileView.backgroundColor = UIColor.white
                cell.addSubview(profileView)
                
                profileView.translatesAutoresizingMaskIntoConstraints = false
                let horizontalConstraint = NSLayoutConstraint(item: profileView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
                let verticalConstraint = NSLayoutConstraint(item: profileView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 150)
                let centeredVertically = NSLayoutConstraint(item: profileView, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
                let widthConstraint = NSLayoutConstraint(item: profileView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
                
                NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, centeredVertically])
                
                let cellHeight = NSLayoutConstraint(item: cell!, attribute: .height, relatedBy: .equal, toItem: profileView, attribute: .height, multiplier: 1, constant: padding)
                NSLayoutConstraint.activate([cellHeight])
            case 1:
                let compareView = HousePointsCompareView.init()
                compareView.layer.shadowColor = UIColor.darkGray.cgColor
                compareView.layer.shadowOpacity = 0.5
                compareView.layer.shadowOffset = CGSize.zero
                compareView.layer.shadowRadius = 5
                compareView.layer.cornerRadius = DefinedValues.radius
                compareView.backgroundColor = UIColor.white
                cell.addSubview(compareView)
                
                compareView.translatesAutoresizingMaskIntoConstraints = false
                let horizontalConstraint = NSLayoutConstraint(item: compareView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
                let verticalConstraint = NSLayoutConstraint(item: compareView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 361)
               let centeredVertically = NSLayoutConstraint(item: compareView, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
                let widthConstraint = NSLayoutConstraint(item: compareView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
                
                NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, centeredVertically])
                
                let cellHeight = NSLayoutConstraint(item: cell!, attribute: .height, relatedBy: .equal, toItem: compareView, attribute: .height, multiplier: 1, constant: padding)
                NSLayoutConstraint.activate([cellHeight])
            case 2:
                let houseView = HousePointsView.init()
                houseView.layer.shadowColor = UIColor.darkGray.cgColor
                houseView.layer.shadowOpacity = 0.5
                houseView.layer.shadowOffset = CGSize.zero
                houseView.layer.shadowRadius = 5
                houseView.layer.cornerRadius = DefinedValues.radius
                houseView.backgroundColor = UIColor.white
                cell.addSubview(houseView)
                
                houseView.translatesAutoresizingMaskIntoConstraints = false
                let horizontalConstraint = NSLayoutConstraint(item: houseView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
                let verticalConstraint = NSLayoutConstraint(item: houseView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 190)
                let centeredVertically = NSLayoutConstraint(item: houseView, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
                let widthConstraint = NSLayoutConstraint(item: houseView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
                
                NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, centeredVertically])
                
                let cellHeight = NSLayoutConstraint(item: cell!, attribute: .height, relatedBy: .equal, toItem: houseView, attribute: .height, multiplier: 1, constant: padding)
                NSLayoutConstraint.activate([cellHeight])
            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: "top_scorers_table_cell", for: indexPath)
                
                cell.contentView.layer.cornerRadius = DefinedValues.radius
                cell.contentView.layer.masksToBounds = true
                cell.contentView.translatesAutoresizingMaskIntoConstraints = false
                let horizontalConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
                let verticalConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 260)
                let centeredVertically = NSLayoutConstraint(item: cell.contentView, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
                let widthConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
                
                NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, centeredVertically])
                
                // Not the best implementation...
                // This removes the view and recreates it with every refresh.
                // This was necessary due to the way the table view inside a
                // table view works. A better implementation would be appreciated.
                view.viewWithTag(3)?.removeFromSuperview()
                let containerView:UIView = UIView(frame: cell.contentView.bounds)
                containerView.tag = 3
                
                containerView.backgroundColor = UIColor.white
                containerView.layer.shadowColor = UIColor.darkGray.cgColor
                containerView.layer.shadowOffset = CGSize.zero
                containerView.layer.shadowOpacity = 0.5
                containerView.layer.shadowRadius = 5
                containerView.layer.cornerRadius = DefinedValues.radius
                cell.insertSubview(containerView, belowSubview: cell.contentView)
                
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
                let topConstraint = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 0)
                let bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: 0)
               let leftConstraint = NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .equal, toItem: cell.contentView, attribute: .left, multiplier: 1, constant: 0)
                let rightConstraint = NSLayoutConstraint(item: containerView, attribute: .right, relatedBy: .equal, toItem: cell.contentView, attribute: .right, multiplier: 1, constant: 0)
                
                NSLayoutConstraint.activate([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
                
                let cellHeight = NSLayoutConstraint(item: cell!, attribute: .height, relatedBy: .equal, toItem: cell.contentView, attribute: .height, multiplier: 1, constant: padding)
                NSLayoutConstraint.activate([cellHeight])
            default:
                break
            }
            cell.backgroundColor = DefinedValues.systemGray5
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "top_scorers_cell", for: indexPath)
            let row = indexPath.row
            if (house != nil) {
                if (row < house!.topScoreUsers!.count) {
                    cell.textLabel!.text = house!.topScoreUsers![row].userName
                }
            }
            
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (tableView.tag == 2) {
            return "Top House Scorers"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (tableView.tag == 1) {
            if (permission == PointType.PermissionLevel.fhp) {
                return 4
            } else {
                return 3
            }
        } else {
            return 5
        }
    }
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        contentView.layer.cornerRadius = DefinedValues.radius
        
        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        p?.layer.cornerRadius = DefinedValues.radius
        
        let reportButton = UIButton.init(frame: CGRect.init(x: distance, y: 115, width: buttonWidth, height: 75))
        reportButton.layer.cornerRadius = DefinedValues.radius
        reportButton.layer.borderWidth = borderWidth
        reportButton.layer.borderColor = color.cgColor
        reportButton.setTitleColor(UIColor.black, for: .normal)
        reportButton.setTitle("Report a bug", for: .normal)
        reportButton.addTarget(self, action: #selector(reportBug), for: .touchUpInside)
        
        let logoutButton = UIButton.init(frame: CGRect.init(x: distance, y: 25, width: buttonWidth, height: 75))
        logoutButton.layer.cornerRadius = DefinedValues.radius
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
    
    func setTopScorersArray(house:House){
        /*for i in 0...house.topScoreUsers!.count {
            topScorers[0] = house.topScoreUsers![i].userName
        }
        if(house.topScoreUsers!.count > 0){
            topScorers[0] = house.topScoreUsers![0].userName
        }
        if(house.topScoreUsers!.count > 1){
            secondPlaceLabel.text = house.topScoreUsers![1].userName
            secondPointsLabel.text = house.topScoreUsers![1].totalPoints.description
        }
        if(house.topScoreUsers!.count > 2){
            thirdPlaceLabel.text = house.topScoreUsers![2].userName
            thirdPointsLabel.text = house.topScoreUsers![2].totalPoints.description
        }
        if(house.topScoreUsers!.count > 3){
            fourthPlaceLabel.text = house.topScoreUsers![3].userName
            fourthPointsLabel.text = house.topScoreUsers![3].totalPoints.description
        }
        if(house.topScoreUsers!.count > 4){
            fifthPlaceLabel.text = house.topScoreUsers![4].userName
            fifthPointsLabel.text = house.topScoreUsers![4].totalPoints.description
        }*/
        
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
