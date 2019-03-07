//
//  AnimatedLoadingViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/23/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import FirebaseAuth
import Cely

class AnimatedLoadingViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var retryButton: UIButton!
    @IBOutlet var signOutButton: UIButton!
    
    let images = [#imageLiteral(resourceName: "Platinum"),#imageLiteral(resourceName: "Copper"),#imageLiteral(resourceName: "Titanium"),#imageLiteral(resourceName: "Silver"),#imageLiteral(resourceName: "Palladium")]
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Cely.currentLoginStatus() == .loggedIn){
			/*
			if(NewLaunch.newLaunch.isFirstLaunch){
                createNewLaunchAlert()
            }*/
			
			self.imageView.image = #imageLiteral(resourceName: "emblem")
			self.imageView.layer.borderWidth = 5
			self.imageView.layer.borderColor = UIColor.black.cgColor
			let height = self.imageView.frame.height
			self.imageView.layer.cornerRadius = height/2
			self.imageView.layer.shadowColor = UIColor.gray.cgColor
			self.imageView.layer.shadowRadius = 2
			self.imageView.layer.shadowOpacity = 100
			self.imageView.layer.shadowOffset = CGSize.init(width: 0, height: 5)
            
            signOutButton.layer.borderWidth = 1.0
            signOutButton.layer.borderColor = UIColor.black.cgColor
            signOutButton.layer.cornerRadius = 5.0
            
            retryButton.layer.borderWidth = 1.0
            retryButton.layer.borderColor = UIColor.black.cgColor
            retryButton.layer.cornerRadius = 5.0
            
            Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(displayTimeoutButtons), userInfo: nil, repeats: false)
            finishLoadinng()

        }
        else{
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func finishLoadinng(){
        resetCount()
        DataManager.sharedManager.initializeData(finished: {(error) in
			if (error == nil) {
                self.activityIndicator.stopAnimating()
				self.performSegue(withIdentifier: "doneWithInit", sender: nil)
			} else if (error!.code == 1) {
				let alertController = UIAlertController.init(title: "Error", message: "Data could not be loaded.", preferredStyle: .alert)
				
				let retryOption = UIAlertAction.init(title: "Try Again", style: .default, handler: { (alert) in
					self.finishLoadinng()
				})
				
				alertController.addAction(retryOption)
				self.addChild(alertController)
				
			} else if (error!.code == 2) {
				let alertController = UIAlertController.init(title: "Failure to Find Account", message: "Please create a new account.", preferredStyle: .alert)
				
				let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (alert) in
					try! Auth.auth().signOut()
					Cely.logout()
				})
				alertController.addAction(okAction)
				self.addChild(alertController)
			}
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setImage() {
        let i = Int(arc4random_uniform(5))
        let toImage = images[i]
        self.imageView.image = toImage
    }
    

    @objc func displayTimeoutButtons() {
        if (self.isViewLoaded && ((self.view?.window) != nil)) {
            // viewController is visible
            retryButton.isHidden = false
            signOutButton.isHidden = false
        }
    }
    
    func hideTimeoutButtons() {
        retryButton.isHidden = true
        signOutButton.isHidden = true
        
    }
    
    private func resetCount(){
        let counter = AppUtils.AtomicCounter(identifier: "initializeData")
        counter.reset()
    }

    
    @IBAction func retryAction(_ sender: Any) {
        resetCount()
        hideTimeoutButtons()
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(displayTimeoutButtons), userInfo: nil, repeats: false)
        finishLoadinng()
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        resetCount()
        hideTimeoutButtons()
        try! Auth.auth().signOut() // Sign out from firebase
        Cely.logout()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
