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

class HouseProfileViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var reportButton: UIButton!
    
    @IBOutlet var profileView: ProfileView!
	@IBOutlet weak var housePointsCompareView: HousePointsCompareView!
	@IBOutlet weak var housePointsView: HousePointsView!
    
    var refresher:UIRefreshControl?
    var refreshCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.refreshControl = refresher
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
		
//        self.reportButton.layer.borderColor = UIColor.black.cgColor
//        self.reportButton.layer.borderWidth = 0
        self.reportButton.layer.shadowColor = UIColor.darkGray.cgColor
        self.reportButton.layer.shadowOpacity = 0.5
        self.reportButton.layer.shadowOffset = CGSize.zero
        self.reportButton.layer.shadowRadius = 5
        
//        self.profileView.layer.borderColor = UIColor.black.cgColor
//        self.profileView.layer.borderWidth = 3
        self.profileView.layer.shadowColor = UIColor.darkGray.cgColor
        self.profileView.layer.shadowOpacity = 0.5
        self.profileView.layer.shadowOffset = CGSize.zero
        self.profileView.layer.shadowRadius = 5
        
//        self.housePointsView.layer.borderColor = UIColor.black.cgColor
//        self.housePointsView.layer.borderWidth = 3
        self.housePointsView.layer.shadowColor = UIColor.darkGray.cgColor
        self.housePointsView.layer.shadowOpacity = 0.5
        self.housePointsView.layer.shadowOffset = CGSize.zero
        self.housePointsView.layer.shadowRadius = 5
        
//        self.housePointsCompareView.layer.borderColor = UIColor.black.cgColor
//        self.housePointsCompareView.layer.borderWidth = 3
        self.housePointsCompareView.layer.shadowColor = UIColor.black.cgColor
        self.housePointsCompareView.layer.shadowOpacity = 0.5
        self.housePointsCompareView.layer.shadowOffset = CGSize.zero
        self.housePointsCompareView.layer.shadowRadius = 5
    }
    @objc func logOut(_ sender: Any) {
        try? Auth.auth().signOut()
        Cely.changeStatus(to: .loggedOut)
    }
	
    
    override func viewDidAppear(_ animated: Bool) {
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

    @IBAction func reportABugLink(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://sites.google.com/view/hcr-points/home")!, options: [:], completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segueToProfilePointView() {
        self.performSegue(withIdentifier: "My_Points", sender: self)
    }


}

