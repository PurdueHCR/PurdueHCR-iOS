//
//  LogInViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import Cely
import FirebaseAuth

extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		self.view.addGestureRecognizer(tap)
	}
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var logInButton: UIButton!
	@IBOutlet weak var forgotPasswordButton: UIButton!
	@IBOutlet weak var imageView: UIImageView!
	
    var fortyPercent = CGFloat(0.0)
    var lastChange = 0.0
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.hideKeyboardWhenTappedAround()
		
		self.imageView.image = #imageLiteral(resourceName: "emblem")
		self.imageView.layer.shadowColor = UIColor.gray.cgColor
		self.imageView.layer.shadowRadius = 2
		self.imageView.layer.shadowOpacity = 100
		self.imageView.layer.shadowOffset = CGSize.init(width: 0, height: 5)
		
		activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)
		
        self.username.delegate = self
        self.password.delegate = self
        fortyPercent = self.view.frame.size.height * CGFloat(0.4)
		
		// Actually use system colors once iOS 13 drops
		let systemGray5 = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1.0)
		
        username.layer.cornerRadius = 10
        username.layer.masksToBounds = true
		username.backgroundColor = systemGray5
        //username.layer.borderWidth = 1
        //username.layer.borderColor = UIColor.lightGray.cgColor
		username.tag = 0
        password.layer.cornerRadius = 10
        password.layer.masksToBounds = true
		password.backgroundColor = systemGray5
        //password.layer.borderWidth = 1
        //password.layer.borderColor = UIColor.lightGray.cgColor
		password.tag = 1
        logInButton.layer.cornerRadius = 10
        logInButton.layer.masksToBounds = true
        //logInButton.layer.borderWidth = 1
        //logInButton.layer.borderColor = UIColor.darkGray.cgColor
		
        // Do any additional setup after loading the view.
    }
	
	@IBAction func nextTextField(_ sender: Any) {
		/*
		if let nextField = username.superview?.viewWithTag(username.tag + 1) as? UITextField {
			nextField.becomeFirstResponder()
		} else {
			// Not found, so remove keyboard.
			username.resignFirstResponder()
		}*/
	}
	
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func login(_ sender: Any) {
		self.logInButton.isEnabled = false
		self.activityIndicator.startAnimating()
		guard let email = username.text, let password = password.text else {
			self.notify(title: "Failed to Log In", subtitle: "Please enter all information.", style: .danger)
			self.logInButton.isEnabled = true
			self.activityIndicator.stopAnimating()
			return
		}
		if(email.isEmpty || password.isEmpty){
			self.notify(title: "Failed to Log In", subtitle: "Please enter all information.", style: .danger)
			self.logInButton.isEnabled = true
			self.activityIndicator.stopAnimating()
			return
		}
		
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			guard let usr = user, error == nil else {
                if(error!.localizedDescription.contains("The password is invalid")){
                    self.notify(title: "Wrong Password", subtitle: "Please try again", style: .danger)
                }
                else if(error!.localizedDescription.contains("There is no user record")){
                    self.notify(title: "Could not find user with that email", subtitle: "Please try again", style: .danger)
                }
                else{
                    self.notify(title: "Failed to Log In", subtitle: error!.localizedDescription, style: .danger)
                }
				
				self.logInButton.isEnabled = true
				self.activityIndicator.stopAnimating()
				return
			}
			//The DataManager will handle setting all the elements in User.properties
			DataManager.sharedManager.getUserWhenLogginIn(id: usr.user.uid, onDone: { (success:Bool) in
				if(success){
					//self.notify(title: "Success", subtitle: "Logging in", style: .success)
					User.save(Auth.auth().currentUser?.uid as Any, as: .id)
					Cely.changeStatus(to: .loggedIn)
					self.activityIndicator.stopAnimating()
				}
				else{
					self.logInButton.isEnabled = true
					self.activityIndicator.stopAnimating()
					self.performSegue(withIdentifier: "code_push", sender: self)
//					try! Auth.auth().signOut()
//					self.notify(title: "Could Not Find User", subtitle: "Please create a new account.", style: .danger)
//					return
				}
			})
		}
    }
	
	@IBAction func forgotPassword(_ sender: Any) {
		var loginTextField: UITextField?
		let alertController = UIAlertController(title: "Password Recovery", message: "Please enter your email address", preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
			
			if loginTextField?.text == "" {
				Auth.auth().sendPasswordReset(withEmail: ("email@email.com")) { (error) in
					if (error == nil) {
						
						self.showErrorAlert(title: "Password reset", msg: "Check your inbox to reset your password")
						
					} else {
						print(error as Any)
						self.showErrorAlert(title: "Unidentified email address", msg: "Please re-enter the email you registered with")
					}
				}
			} else {
				Auth.auth().sendPasswordReset(withEmail: (loginTextField?.text)!) { (error) in
					if (error == nil) {
						
						self.showErrorAlert(title: "Password reset", msg: "Check your inbox to reset your password")
						
					} else {
						print(error as Any)
						self.showErrorAlert(title: "Unidentified email address", msg: "Please re-enter the email you registered with")
					}
				}
			}
			
			print("textfield is empty")
			
		})
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
			
		}
		alertController.addAction(ok)
		alertController.addAction(cancel)
		alertController.addTextField { (textField) -> Void in
			// Enter the textfiled customization code here.
			loginTextField = textField
			loginTextField?.placeholder = "Enter your login ID"
		}
		present(alertController, animated: true, completion: nil)
	}
	
	func showErrorAlert(title: String, msg: String) {
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	/*
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
    }*/
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //moveTextField(textField: textField, up: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        //moveTextField(textField: textField, up: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

	
}
