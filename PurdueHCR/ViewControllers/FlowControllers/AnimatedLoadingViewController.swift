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
    
    let images = [#imageLiteral(resourceName: "Platinum"),#imageLiteral(resourceName: "Copper"),#imageLiteral(resourceName: "Titanium"),#imageLiteral(resourceName: "Silver"),#imageLiteral(resourceName: "Palladium")]
    
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
            finishLoadinng()

        }
        else{
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func finishLoadinng(){
        DataManager.sharedManager.initializeData(finished: {(error) in
			if (error == nil) {
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
    
    //This will be for showing announcements
	/*
	func createNewLaunchAlert(){
        let alert = UIAlertController(title: "Are you interested in joining Development Committee?", message: "Development Committee is looking for software developers, marketers, and designers to help with the future of Purdue HCR. If you are interested in helping, checkout our Discord channel!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Take me to the Discord", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            UIApplication.shared.open(URL(string: "https://discord.gg/jptXrYG")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            self.finishLoadinng()
        }))
        alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertAction.Style.default, handler: {(action)in
            alert.dismiss(animated: true, completion: self.finishLoadinng)
            self.finishLoadinng()
        }))
        self.present(alert, animated: true, completion: nil)
    }
	*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
