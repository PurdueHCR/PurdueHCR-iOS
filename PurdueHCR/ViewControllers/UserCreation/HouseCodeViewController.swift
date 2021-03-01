//
//  HouseCodeViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 7/17/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Cely

class HouseCodeViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var firstNameField: UITextField!
	@IBOutlet weak var lastNameField: UITextField!
	@IBOutlet weak var codeField: UITextField!
	@IBOutlet weak var joinButton: UIButton!
	
	var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
	
	var fortyPercent = CGFloat(0.0)
	var lastChange = 0.0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let systemGray5 = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1.0)
		
		fortyPercent = self.view.frame.size.height * 0.4
		self.firstNameField.delegate = self
		self.lastNameField.delegate = self
		self.codeField.delegate = self
		
		firstNameField.layer.cornerRadius = 10
		firstNameField.layer.masksToBounds = true
		firstNameField.backgroundColor = systemGray5
		
		lastNameField.layer.cornerRadius = 10
		lastNameField.layer.masksToBounds = true
		lastNameField.backgroundColor = systemGray5
		
		codeField.layer.cornerRadius = 10
		codeField.layer.masksToBounds = true
		codeField.backgroundColor = systemGray5
		
		joinButton.layer.cornerRadius = 10
		joinButton.layer.masksToBounds = true
		
		activityIndicator.center = self.view.center
		activityIndicator.hidesWhenStopped = true
		activityIndicator.style = UIActivityIndicatorView.Style.gray
		self.view.addSubview(activityIndicator)
		
		self.hideKeyboardWhenTappedAround()
        
        // For when user has been created using link
        if (SignUpViewController.houseCode != nil) {
            codeField.text = SignUpViewController.houseCode
        }
		
	}
    
	@IBAction func joinHouse(_ sender: Any) {
	
		let firstName = firstNameField.text
		let lastName = lastNameField.text
		let code = codeField.text
		
        self.joinButton.isEnabled = false
		
		// TODO: Determine what the correct test case of this is
		if (firstName == "" || lastName == ""){
			self.notify(title: "Failed to Sign Up", subtitle: "Please enter your preferred first and last name.", style: .danger)
			self.joinButton.isEnabled = true
			self.activityIndicator.stopAnimating()
		}
		else if(!codeIsValid(code:code!)){
			self.notify(title: "Failed to Sign Up", subtitle: "Code is invalid.", style: .danger)
			self.joinButton.isEnabled = true
			self.activityIndicator.stopAnimating()
		}
		else {
			// find the house that their code matches and go to the database and create their user
			//

			User.save(Auth.auth().currentUser?.uid, as: .id)
			User.save(firstName as Any, as: .firstName)
			User.save(lastName as Any, as: .lastName)
			DataManager.sharedManager.createUser(onDone: ({ (err:Error?) in
				if err != nil {
					self.notify(title: "Failed to Create Profile", subtitle: "Failed to join house.", style: .danger)
					self.joinButton.isEnabled = true
					self.activityIndicator.stopAnimating()
					try! Auth.auth().signOut()
				} else {
					self.initializeData()
				}
			}))
		}
	
	}
	
	func initializeData() {
		DataManager.sharedManager.initializeData(finished:{(initError) in
			if (initError == nil) {
				
				Cely.changeStatus(to: .loggedIn)
				self.activityIndicator.stopAnimating()
			} else if (initError!.code == 1) {
				let alertController = UIAlertController.init(title: "Error", message: "Data could not be loaded.", preferredStyle: .alert)
				
				let retryOption = UIAlertAction.init(title: "Try Again", style: .default, handler: { (alert) in
					self.initializeData()
				})
				
				alertController.addAction(retryOption)
				self.addChild(alertController)
				
			} else if (initError!.code == 2) {
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
	
	
	// code is format [houseIdentifier:roomNumber]
	func codeIsValid(code:String)-> Bool{
		let codes = DataManager.sharedManager.getHouseCodes()!
		for houseCode in codes {
			if (code == houseCode.code){
				User.save(houseCode.house, as: .house)
				User.save(houseCode.floorID, as: .floorID)
				User.save(houseCode.permissionLevel as Any, as: .permissionLevel)
				User.save(0 as Any, as: .points)
				return true
			}
		}
		return false
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		moveTextField(textField: textField, up: true)
	}

	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
		moveTextField(textField: textField, up: false)
	}
	
	func moveTextField(textField:UITextField, up:Bool){
		if(up && textField.frame.minY > self.fortyPercent){
			let movement = self.fortyPercent - textField.frame.minY
			self.lastChange = Double(movement)
			UIView.beginAnimations("TextFieldMove", context: nil)
			UIView.setAnimationBeginsFromCurrentState(true)
			UIView.setAnimationDuration(0.3)
			self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
			UIView.commitAnimations()
		}
		else if(!up && self.lastChange != 0.0){
			let movement = CGFloat(self.lastChange * -1.0)
			self.lastChange = 0.0
			UIView.beginAnimations("TextFieldMove", context: nil)
			UIView.setAnimationBeginsFromCurrentState(true)
			UIView.setAnimationDuration(0.3)
			self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
			UIView.commitAnimations()
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
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
