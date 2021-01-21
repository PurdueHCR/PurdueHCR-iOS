//
//  HouseCompetitionOverviewTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 10/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import FirebaseAuth
import Cely
import PopupKit
import NotificationBannerSwift

class HouseCompetitionOverviewTableViewController: UITableViewController {

    @IBOutlet var houseGraph: HousePointsCompareView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
	@IBOutlet weak var competitionEnabledSwitch: UISwitch!
    @IBOutlet weak var competitionVisibleSwitch: UISwitch!
    
    let houses = ["Copper","Palladium","Platinum","Silver","Titanium"]
    @IBOutlet var houseSelectionControl: UISegmentedControl!
    @IBOutlet var firstPlaceLabel: UILabel!
    @IBOutlet var firstPointsLabel: UILabel!
    @IBOutlet var secondPlaceLabel: UILabel!
    @IBOutlet var secondPointsLabel: UILabel!
    @IBOutlet var thirdPlaceLabel: UILabel!
    @IBOutlet var thirdPointsLabel: UILabel!
    @IBOutlet var fourthPlaceLabel: UILabel!
    @IBOutlet var fourthPointsLabel: UILabel!
    @IBOutlet var fifthPlaceLabel: UILabel!
    @IBOutlet var fifthPointsLabel: UILabel!
    
    var radius : CGFloat = 10
    var p : PopupView?
    
    var refresher: UIRefreshControl?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        setPlaceLabels(house: getHouseWithName(name: "Copper")!)
		competitionEnabledSwitch.isOn = DataManager.sharedManager.systemPreferences!.isHouseEnabled
        competitionVisibleSwitch.isOn = DataManager.sharedManager.systemPreferences!.isCompetitionVisible
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func setPlaceLabels(house:House){
        firstPlaceLabel.text = "No User"
        firstPointsLabel.text = ""
        secondPlaceLabel.text = "No User"
        secondPointsLabel.text = ""
        thirdPlaceLabel.text = "No User"
        thirdPointsLabel.text = ""
        fourthPlaceLabel.text = "No User"
        fourthPointsLabel.text = ""
        fifthPlaceLabel.text = "No User"
        fifthPointsLabel.text = ""
        if(house.topScoreUsers!.count > 0){
            firstPlaceLabel.text = house.topScoreUsers![0].userName
            firstPointsLabel.text = house.topScoreUsers![0].totalPoints.description
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
        }
        
    }

    @IBAction func selectHouse(_ sender: UISegmentedControl) {
        setPlaceLabels(house: getHouseWithName(name: self.houses[houseSelectionControl.selectedSegmentIndex])!)
    }
    
    @IBAction func openSettings(_ sender: Any) {
        
        /*let width : Int = Int(self.view.frame.width - 20)
        let height = 280
        let distance = 20
        let buttonWidth = width - (distance * 2)
        let borderWidth : CGFloat = 2
		let color = UIColor.lightGray
        
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
        //button.backgroundColor = color
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
        p?.show(at: location, in: (self.tabBarController?.view)!)*/
        
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
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: (self.tabBarController?.view)!)
    }
    
    @objc func dismissRECLogout() {
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
	
	@IBAction func changeHouseEnabledStatus(_ sender: Any) {
		if (competitionEnabledSwitch.isOn) {
			let alertController = UIAlertController(title: "Enable House Competition", message: "Are you sure you want to enable the House Competition?", preferredStyle: .alert)
			let confirm = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
				DataManager.sharedManager.systemPreferences?.isHouseEnabled = self.competitionEnabledSwitch.isOn
				DataManager.sharedManager.updateSystemPreferences(withCompletion: { (err) in
					if (err == nil) {
						self.notify(title: "House Competition Enabled", subtitle: "The House Competition was successfully enabled.", style: .success)
					} else {
						self.notify(title: "House Competition was not updated.", subtitle: "There was an error.", style: .success)
						self.competitionEnabledSwitch.setOn(false, animated: true)
						DataManager.sharedManager.systemPreferences?.isHouseEnabled = self.competitionEnabledSwitch.isOn
					}
				})
			})
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
				self.competitionEnabledSwitch.setOn(false, animated: true)
			}
			alertController.addAction(confirm)
			alertController.addAction(cancel)
			present(alertController, animated: true, completion: nil)
		}
		else {
			var loginTextField: UITextField?
			//var disabledMessage : String?
			let alertController = UIAlertController(title: "Disable House Competition", message: "Enter a message explaining why the house competition is suspended.", preferredStyle: .alert)
			alertController.addTextField { (textField) -> Void in
				// Enter the textfield customization code here.
				loginTextField = textField
				loginTextField?.placeholder = "Enter a message"
			}
			let confirm = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
				DataManager.sharedManager.systemPreferences?.isHouseEnabled = self.competitionEnabledSwitch.isOn
				DataManager.sharedManager.systemPreferences?.houseEnabledMessage = loginTextField!.text!
				DataManager.sharedManager.updateSystemPreferences(withCompletion: { (err) in
					if (err == nil) {
						self.notify(title: "House Competition Disabled", subtitle: "The House Competition was successfully disabled.", style: .success)
					} else {
						self.notify(title: "House Competition was not updated.", subtitle: "There was an error.", style: .success)
						self.competitionEnabledSwitch.setOn(true, animated: true)
						DataManager.sharedManager.systemPreferences?.isHouseEnabled = self.competitionEnabledSwitch.isOn
					}
				})
			})
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
				self.competitionEnabledSwitch.setOn(true, animated: true)
			}
			alertController.addAction(confirm)
			alertController.addAction(cancel)
			present(alertController, animated: true, completion: nil)
		}
	}
    
    @IBAction func changeCompetitionVisibleStatus(_ sender: Any) {
        if (competitionVisibleSwitch.isOn) {
            let alertController = UIAlertController(title: "Make House Competition Visible", message: "Are you sure you want to make the House Competition visible to residents?", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                DataManager.sharedManager.systemPreferences?.isCompetitionVisible = self.competitionVisibleSwitch.isOn
                DataManager.sharedManager.updateSystemPreferences(withCompletion: { (err) in
                    if (err == nil) {
                        self.notify(title: "House Competition Visible", subtitle: "House Competition visibility was successfully enabled.", style: .success)
                    } else {
                        self.notify(title: "House Competition was not updated.", subtitle: "There was an error.", style: .success)
                        self.competitionVisibleSwitch.setOn(false, animated: true)
                        DataManager.sharedManager.systemPreferences?.isCompetitionVisible = self.competitionVisibleSwitch.isOn
                    }
                })
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                self.competitionVisibleSwitch.setOn(false, animated: true)
            }
            alertController.addAction(confirm)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        }
        else {
            var loginTextField: UITextField?
            //var disabledMessage : String?
            let alertController = UIAlertController(title: "Disable House Competition Visibility", message: "Enter a message explaining why the house competition is not visible to residents.", preferredStyle: .alert)
            alertController.addTextField { (textField) -> Void in
                // Enter the textfield customization code here.
                loginTextField = textField
                loginTextField?.placeholder = "Enter a message"
            }
            let confirm = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                DataManager.sharedManager.systemPreferences?.isCompetitionVisible = self.competitionVisibleSwitch.isOn
                DataManager.sharedManager.systemPreferences?.competitionHiddenMessage = loginTextField!.text!
                DataManager.sharedManager.updateSystemPreferences(withCompletion: { (err) in
                    if (err == nil) {
                        self.notify(title: "House Competition Visibility Disabled", subtitle: "House Competition visibility was successfully disabled.", style: .success)
                    } else {
                        self.notify(title: "House Competition was not updated.", subtitle: "There was an error.", style: .success)
                        self.competitionVisibleSwitch.setOn(true, animated: true)
                        DataManager.sharedManager.systemPreferences?.isCompetitionVisible = self.competitionVisibleSwitch.isOn
                    }
                })
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                self.competitionVisibleSwitch.setOn(true, animated: true)
            }
            alertController.addAction(confirm)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        }
    }
    
	
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "show_point_breakdown"){
            // get a reference to the second view controller
            let nextViewController = segue.destination as! HouseTableViewController
            nextViewController.houseName = self.houses[houseSelectionControl.selectedSegmentIndex]
        }
        else if( segue.identifier == "show_give_award"){
            let nextViewController = segue.destination as! SubmitGrantedAwardViewController
            nextViewController.house = self.getHouseWithName(name: self.houses[houseSelectionControl.selectedSegmentIndex])
        }
        
    }
    
    func getHouseWithName(name:String) -> House?{
        for house in DataManager.sharedManager.getHouses()!{
            if house.houseID == name{
                return house
            }
        }
        return nil
    }

    
    @objc func refreshData(){
        DataManager.sharedManager.refreshHouses(onDone: {(hs:[House]) in
            self.houseGraph.refreshDataSet()
            DataManager.sharedManager.getHouseScorers {
                self.selectHouse(self.houseSelectionControl)
                self.refreshControl?.endRefreshing()
            }
            
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

