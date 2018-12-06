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


class HouseProfileViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet var profileView: ProfileView!
	@IBOutlet weak var housePointsCompareView: HousePointsCompareView!
	@IBOutlet weak var housePointsView: HousePointsView!
    
    var refresher:UIRefreshControl?
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
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
		
        self.profileView.layer.shadowColor = UIColor.darkGray.cgColor
        self.profileView.layer.shadowOpacity = 0.5
        self.profileView.layer.shadowOffset = CGSize.zero
        self.profileView.layer.shadowRadius = 5
        self.profileView.layer.cornerRadius = radius
		
        self.housePointsView.layer.shadowColor = UIColor.darkGray.cgColor
        self.housePointsView.layer.shadowOpacity = 0.5
        self.housePointsView.layer.shadowOffset = CGSize.zero
        self.housePointsView.layer.shadowRadius = 5
        self.housePointsView.layer.cornerRadius = radius
        
        self.housePointsCompareView.layer.shadowColor = UIColor.black.cgColor
        self.housePointsCompareView.layer.shadowOpacity = 0.5
        self.housePointsCompareView.layer.shadowOffset = CGSize.zero
        self.housePointsCompareView.layer.shadowRadius = 5
        self.housePointsCompareView.layer.cornerRadius = radius
        
    }
//    @objc func logOut(_ sender: Any) {
//        try? Auth.auth().signOut()
//        Cely.changeStatus(to: .loggedOut)
//    }
	
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
		
        var houses = DataManager.sharedManager.getHouses()!
        self.house = houses.remove(at: houses.index(of: House(id: User.get(.house) as! String, points: 0,hexColor:"",numberOfResidents: 0))!)
        
        let color = AppUtils.hexStringToUIColor(hex: house!.hexColor)
        
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

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}


