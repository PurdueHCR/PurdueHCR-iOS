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
    let padding : CGFloat = 10
    let shadowRadius : CGFloat = 7
    var permission: PointType.PermissionLevel?
    var houseImageView: UIImageView!
    var showRewards = true
    
    var profileView: ProfileView?
    var compareView: HousePointsCompareView?
    var houseView: HousePointsView?
    var topScorersView: TopScorersView?
   
    var messageLogs = [PointLog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        // Commented out since do not want to display what's new on this version
//        let defaults = UserDefaults.standard
//        if let new_version = defaults.object(forKey: "last_opened_version") {
//            if ((new_version as! String) != appVersion) {
//                self.performSegue(withIdentifier: "show_whats_new", sender: self)
//                defaults.setValue(appVersion, forKey: "last_opened_version")
//            }
//        } else {
//            self.performSegue(withIdentifier: "show_whats_new", sender: self)
//            defaults.setValue(appVersion, forKey: "last_opened_version")
//        }
        
        
        let firstName = User.get(.firstName) as! String
        let lastName = User.get(.lastName) as! String
        self.navigationItem.title = firstName + " " + lastName
        
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        
        permission = PointType.PermissionLevel.init(rawValue: User.get(.permissionLevel) as! Int)!
        if (permission == PointType.PermissionLevel.faculty) {
            let navigationBar = navigationController!.navigationBar
			self.navigationItem.rightBarButtonItems = nil
            let houseName = User.get(.house) as! String
            houseImageView = UIImageView()
            if(houseName == "Platinum"){
                houseImageView.image = #imageLiteral(resourceName: "Platinum")
            }
            else if(houseName == "Copper"){
                houseImageView.image = #imageLiteral(resourceName: "Copper")
            }
            else if(houseName == "Palladium"){
                houseImageView.image = #imageLiteral(resourceName: "Palladium")
            }
            else if(houseName == "Silver"){
                houseImageView.image = #imageLiteral(resourceName: "Silver")
            }
            else if(houseName == "Titanium"){
                houseImageView.image = #imageLiteral(resourceName: "Titanium")
            }
            navigationBar.addSubview(houseImageView)
            houseImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
            houseImageView.clipsToBounds = true
            houseImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                houseImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
                houseImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
                houseImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
                houseImageView.widthAnchor.constraint(equalTo: houseImageView.heightAnchor)
                ])
		}
        else if (permission == PointType.PermissionLevel.ea) {
            self.navigationItem.rightBarButtonItems = nil
        }
        /*if #available(iOS 13.0, *) {
            backgroundTable.backgroundColor = UIColor.systemGray5
        } else {
            backgroundTable.backgroundColor = DefinedValues.systemGray5
        }*/
        //backgroundTable.backgroundColor = UIColor.white
		
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
			if (sysPref?.iosVersion != appVersion) {
				let alertController = UIAlertController.init(title: "Update Available", message: "It looks like you do not have the newest version of PurdueHCR. Please update as soon as posible to ensure you get all the latest and greatest features!", preferredStyle: .alert)
				let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: .none)
				alertController.addAction(okAction)
				self.present(alertController, animated: true, completion: .none)
			}
		}
        showRewards = DataManager.sharedManager.systemPreferences!.showRewards
        
        refreshData()
    
    }
	
    // TODO: Fix refreshing of views
    @objc func refreshData() {
        
        // I'm not sure this is the best way to do this...
        profileView = nil
        compareView = nil
        houseView = nil
        topScorersView = nil
		refreshCount = 0
        DataManager.sharedManager.refreshUser(onDone: {(err:Error?) in
            self.handleRefresher()
        })
        DataManager.sharedManager.refreshHouses(onDone: {(hs:[House]) in
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
                self.messageLogs = pointLogs
                self.messageLogs.sort(by: {$0.dateSubmitted!.dateValue() > $1.dateSubmitted!.dateValue()})
			})
        }
        tableView.reloadData()
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
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.clipsToBounds = false
        cell.layer.masksToBounds = false
        
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        
        let row = indexPath.row
        let isFHP = (permission == PointType.PermissionLevel.faculty)
        let isEA = (permission == PointType.PermissionLevel.ea)
        let showProfileView = row == 0 && !isFHP && !isEA
        let showCompareView = (!isFHP && !isEA && row == 1) || ((isFHP || isEA) && row == 0)
        let showRewardsView = ((!isFHP && !isEA && row == 2) || (isFHP && row == 1)) && showRewards
        let showTopScorersView = isFHP && row == 2 || (isFHP && row == 1 && !showRewards)
    
        if (showProfileView) {
            if (profileView == nil) {
                profileView = ProfileView.init()
//                profileView?.layer.shadowColor = UIColor.darkGray.cgColor
//                profileView?.layer.shadowOpacity = 0.5
//                profileView?.layer.shadowOffset = CGSize.zero
//                profileView?.layer.shadowRadius = shadowRadius
                profileView?.layer.cornerRadius = DefinedValues.radius
                profileView?.backgroundColor = UIColor.white
                profileView?.clipsToBounds = false
                profileView?.layer.masksToBounds = false
                profileView?.delegate = self
            }
            cell.contentView.clipsToBounds = false
            cell.clipsToBounds = false
            cell.addSubview(profileView!)
            
            profileView?.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: profileView!, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: profileView!, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 150)
            let centeredVertically = NSLayoutConstraint(item: profileView!, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 3)
            let widthConstraint = NSLayoutConstraint(item: profileView!, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, centeredVertically])
            
            let cellHeight = NSLayoutConstraint(item: cell!, attribute: .height, relatedBy: .equal, toItem: profileView, attribute: .height, multiplier: 1, constant: padding+5)
            NSLayoutConstraint.activate([cellHeight])
        }
        else if (showCompareView) {
            if (compareView == nil) {
                compareView = HousePointsCompareView.init()
//                compareView?.layer.shadowColor = UIColor.darkGray.cgColor
//                compareView?.layer.shadowOpacity = 0.5
//                compareView?.layer.shadowOffset = CGSize.zero
//                compareView?.layer.shadowRadius = shadowRadius
                compareView?.layer.cornerRadius = DefinedValues.radius
                compareView?.clipsToBounds = false
                compareView?.layer.masksToBounds = false
                compareView?.backgroundColor = UIColor.white
            }
            cell.contentView.clipsToBounds = false
            cell.clipsToBounds = false
            cell.addSubview(compareView!)
            
            compareView?.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: compareView!, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: compareView!, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 361)
           let centeredVertically = NSLayoutConstraint(item: compareView!, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: compareView!, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, centeredVertically])
            
            let cellHeight = NSLayoutConstraint(item: cell!, attribute: .height, relatedBy: .equal, toItem: compareView, attribute: .height, multiplier: 1, constant: padding)
            NSLayoutConstraint.activate([cellHeight])
        }
        else if (showRewardsView) {
            if (houseView == nil) {
                houseView = HousePointsView.init()
//                houseView?.layer.shadowColor = UIColor.darkGray.cgColor
//                houseView?.layer.shadowOpacity = 0.5
//                houseView?.layer.shadowOffset = CGSize.zero
//                houseView?.layer.shadowRadius = shadowRadius
                houseView?.layer.cornerRadius = DefinedValues.radius
                //houseView?.backgroundColor = UIColor.white
            }
            cell.addSubview(houseView!)
            
            houseView?.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: houseView!, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: houseView!, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 190)
            let centeredVertically = NSLayoutConstraint(item: houseView!, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: houseView!, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, centeredVertically])
            
            let cellHeight = NSLayoutConstraint(item: cell!, attribute: .height, relatedBy: .equal, toItem: houseView, attribute: .height, multiplier: 1, constant: padding)
            NSLayoutConstraint.activate([cellHeight])
        }
        else if (showTopScorersView) {
            if (topScorersView == nil) {
                topScorersView = TopScorersView.init()
//                topScorersView?.layer.shadowColor = UIColor.darkGray.cgColor
//                topScorersView?.layer.shadowOpacity = 0.5
//                topScorersView?.layer.shadowOffset = CGSize.zero
//                topScorersView?.layer.shadowRadius = shadowRadius
                topScorersView?.layer.cornerRadius = DefinedValues.radius
                //topScorersView?.backgroundColor = UIColor.white
                topScorersView?.autoresizingMask = [.flexibleHeight]
                topScorersView?.sizeToFit()
            }
            cell.addSubview(topScorersView!)
            
            topScorersView?.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: topScorersView!, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            let centeredVertically = NSLayoutConstraint(item: topScorersView!, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: topScorersView!, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
                           
            NSLayoutConstraint.activate([horizontalConstraint, widthConstraint, centeredVertically])
            
            let cellHeight = NSLayoutConstraint(item: cell!, attribute: .height, relatedBy: .equal, toItem: topScorersView, attribute: .height, multiplier: 1, constant: padding+5)
            NSLayoutConstraint.activate([cellHeight])
        }
        //cell.backgroundColor = UIColor.white//DefinedValues.systemGray5
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (showRewards) {
            return 3
        } else {
            return 2
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
        
        let width : Int = Int(self.view.frame.width - 20)
        let height = 540
        
        let contentView = LogoutView(frame: CGRect(x: 0, y:0, width: width, height: height))
        contentView.delegate = self
        
        p = PopupView.init(contentView: contentView)
        p?.maskType = .dimmed
        p?.layer.cornerRadius = DefinedValues.radius

        
        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height / 2
        let location = CGPoint.init(x: xPos, y: yPos)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: (self.tabBarController?.view)!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "show_notifications") {
            self.notificationsButton.setImage(#imageLiteral(resourceName: "Bell"), for: .normal)
            let nextVC = segue.destination as! NotificationsTableViewController
            nextVC.displayedLogs = messageLogs
        }
    }
    
    func buttonAction() {
        p?.dismissType = .slideOutToBottom
        p?.dismiss(animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (permission == PointType.PermissionLevel.faculty) {
            guard let height = navigationController?.navigationBar.frame.height else { return }
            moveAndResizeImage(for: height)
        }
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)

        houseImageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    /// WARNING: Change these constants according to your project's design
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 16
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}


// View to display the What's New Page
//
// I left this inside this file since they
// are on the same storyboard and this view
// requires almost no code.
class whatsNewViewController: UIViewController {
    
    @IBOutlet weak var eventIcon: UIImageView!
    @IBOutlet weak var qrCodeIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventIcon.image = #imageLiteral(resourceName: "SF_calendar_badge_plus").withRenderingMode(.alwaysTemplate)
        eventIcon.tintColor = DefinedValues.systemBlue
        qrCodeIcon.image = #imageLiteral(resourceName: "QRCode").withRenderingMode(.alwaysTemplate)
        qrCodeIcon.tintColor = DefinedValues.systemBlue
    }
    
    @IBAction func dismissWhatsNew(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
