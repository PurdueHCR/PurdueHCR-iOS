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
    
    @IBOutlet var colorAndPictureView: ColorAndPictureView!
    @IBOutlet var profileView: ProfileView!
    @IBOutlet var housePointsView: HousePointsView!
    @IBOutlet var housePointsCompareView: HousePointsCompareView!
    
    var refresher:UIRefreshControl?
    var refreshCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.refreshControl = refresher
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
        
        self.reportButton.layer.borderColor = UIColor.black.cgColor
        self.reportButton.layer.borderWidth = 1
    }
    @objc func logOut(_ sender: Any) {
        try? Auth.auth().signOut()
        Cely.logout()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        refreshData()
    }
    
    @objc func refreshData(){
        refreshCount = 0
        DataManager.sharedManager.refreshUser(onDone: {(err:Error?) in
            self.profileView.reloadData()
            self.colorAndPictureView.refresh()
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
        UIApplication.shared.openURL(URL(string: "https://sites.google.com/view/hcr-points/home")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segueToProfilePointView() {
        self.performSegue(withIdentifier: "My_Points", sender: self)
    }


}

