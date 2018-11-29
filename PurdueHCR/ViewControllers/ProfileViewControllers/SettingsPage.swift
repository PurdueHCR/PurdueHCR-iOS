//
//  SettingsPage.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 11/6/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import FirebaseAuth
import Cely

class SettingsPage: UIViewController {

	@IBOutlet weak var logOutButton: UIButton!
	@IBOutlet weak var logOutView: UIView!
	@IBOutlet weak var reportButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		self.logOutView.layer.cornerRadius = 0
		self.logOutView.layer.shadowColor = UIColor.darkGray.cgColor
		self.logOutView.layer.shadowOffset = CGSize.zero
		self.logOutView.layer.shadowRadius = 5
		self.logOutView.layer.shadowOpacity = 0.5
		
		self.reportButton.layer.shadowColor = UIColor.darkGray.cgColor
		self.reportButton.layer.shadowOpacity = 0.5
		self.reportButton.layer.shadowOffset = CGSize.zero
		self.reportButton.layer.shadowRadius = 5
		self.reportButton.layer.cornerRadius = 0
		
    }
    
	@IBAction func logOut(_ sender: Any) {
	
		let alert = UIAlertController.init(title: "Log out?", message: "Are you sure you want to log out?", preferredStyle: .alert)
		
		let noAction = UIAlertAction.init(title: "No", style: .default) { (action) in
		}
		let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
			
			try? Auth.auth().signOut()
			Cely.logout()
			
			
		}
		
		alert.addAction(yesAction)
		alert.addAction(noAction)
		
		self.present(alert, animated: true)
		
	}
	
	@IBAction func report(_ sender: Any) {
		UIApplication.shared.open(URL(string: "https://sites.google.com/view/hcr-points/home")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
	}
	
	
	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
