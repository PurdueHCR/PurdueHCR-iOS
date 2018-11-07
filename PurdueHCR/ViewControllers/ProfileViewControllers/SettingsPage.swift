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
	@IBOutlet weak var forgotPasswordButton: UIButton!
	@IBOutlet weak var logOutView: UIView!
	@IBOutlet weak var forgotPasswordView: UIView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		logOutView.layer.cornerRadius = 10
		logOutView.layer.shadowColor = UIColor.black.cgColor
		logOutView.layer.shadowOffset = CGSize.zero
		logOutView.layer.shadowRadius = 5
		logOutView.layer.shadowOpacity = 0.5
		
		forgotPasswordView.layer.cornerRadius = 10
		forgotPasswordView.layer.shadowColor = UIColor.black.cgColor
		forgotPasswordView.layer.shadowOffset = CGSize.zero
		forgotPasswordView.layer.shadowRadius = 5
		forgotPasswordView.layer.shadowOpacity = 0.5
		
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
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
