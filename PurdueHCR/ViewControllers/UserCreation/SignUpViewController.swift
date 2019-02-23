//
//  SignUpViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/14/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Cely

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var verifyPasswordField: UITextField!
    @IBOutlet var codeField: UITextField!
    @IBOutlet var signUpButton: UIButton!
	@IBOutlet weak var imageView: UIImageView!
	
    
    var fortyPercent = CGFloat(0.0)
    var lastChange = 0.0
    var houses:[House]?
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.hideKeyboardWhenTappedAround()
		
		self.imageView.image = #imageLiteral(resourceName: "emblem")
		self.imageView.layer.shadowColor = UIColor.gray.cgColor
		self.imageView.layer.shadowRadius = 2
		self.imageView.layer.shadowOpacity = 100
		self.imageView.layer.shadowOffset = CGSize.init(width: 0, height: 5)
		
		DataManager.sharedManager.refreshHouses(onDone: {(h:[House]) in
            self.houses = h
        })
		
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)
        
        fortyPercent = self.view.frame.size.height * 0.4
        self.emailField.delegate = self
        self.nameField.delegate = self
        self.passwordField.delegate = self
        self.verifyPasswordField.delegate = self
        self.codeField.delegate = self
        
        emailField.layer.cornerRadius = 5
        emailField.layer.masksToBounds = true
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.black.cgColor
        nameField.layer.cornerRadius = 5
        nameField.layer.masksToBounds = true
        nameField.layer.borderWidth = 1
        nameField.layer.borderColor = UIColor.black.cgColor
        passwordField.layer.cornerRadius = 5
        passwordField.layer.masksToBounds = true
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.black.cgColor
        verifyPasswordField.layer.cornerRadius = 5
        verifyPasswordField.layer.masksToBounds = true
        verifyPasswordField.layer.borderWidth = 1
        verifyPasswordField.layer.borderColor = UIColor.black.cgColor
        codeField.layer.cornerRadius = 5
        codeField.layer.masksToBounds = true
        codeField.layer.borderWidth = 1
        codeField.layer.borderColor = UIColor.black.cgColor
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.masksToBounds = true
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.black.cgColor
        
        
    }
    
    @IBAction func submitSignUp(_ sender: Any) {
        self.signUpButton.isEnabled = false
        self.activityIndicator.startAnimating()
        let email = emailField.text
        let password = passwordField.text
        let verifyPassword = verifyPasswordField.text
        let name = nameField.text
        let code = codeField.text
        
        
        
        if( hasEmptyFields(emailOptional: email, passwordOptional: password, verifyPasswordOptional: verifyPassword, nameOptional: name, codeOptional: code)){
            self.notify(title: "Failed to Sign Up", subtitle: "Please enter all information.", style: .danger)
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
        else if ( password! != verifyPassword){
            self.notify(title: "Failed to Sign Up", subtitle: "Please verify your passwords are the same.", style: .danger)
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
        else if ( name?.split(separator: " ").count != 2){
            self.notify(title: "Failed to Sign Up", subtitle: "Please enter your preferred first and last name.", style: .danger)
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
        else if ( !isValidEmail(testStr: email!)){
            self.notify(title: "Failed to Sign Up", subtitle: "Please enter a valid Purdue email address.", style: .danger)
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
        else if(!codeIsValid(code:code!)){
            self.notify(title: "Failed to Sign Up", subtitle: "Code is Invalid.", style: .danger)
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
        else{
            // user is fine to authenticate
            
            Auth.auth().createUser(withEmail: email!, password: password!) { (authResult, error) in
                guard let user = authResult?.user, error == nil else {
                    self.notify(title: "Failed to Sign Up", subtitle: error!.localizedDescription, style: .danger)
                    self.signUpButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    return
                }
                //they are signed in
                // find the house that their code matches and go to the database and create their user
                //
                User.save(name as Any, as: .name)
                User.save(user.uid, as: .id)
                DataManager.sharedManager.createUser(onDone: ({ (err:Error?) in
                    if err != nil {
                        self.notify(title: "Failed to Sign Up", subtitle: "Failed to create user.", style: .danger)
                        self.signUpButton.isEnabled = true
                        self.activityIndicator.stopAnimating()
                        try! Auth.auth().signOut()
                    } else {
						self.initializeData()
                    }
                }))
            }
        }
        
        
    }
	
	func initializeData() {
		DataManager.sharedManager.initializeData(finished:{(initError) in
		if (initError == nil) {
			Cely.changeStatus(to: .loggedIn)
			self.activityIndicator.stopAnimating()
		} else if (initError!.code == 1) {
			let alertController = UIAlertController.init(title: "Error", message: initError!.domain, preferredStyle: .alert)
			
			let retryOption = UIAlertAction.init(title: "Try Again", style: .default, handler: { (alert) in
				self.initializeData()
			})
			
			alertController.addAction(retryOption)
			self.addChild(alertController)
			
		} else if (initError!.code == 2) {
			let alertController = UIAlertController.init(title: "Error", message: initError!.domain, preferredStyle: .alert)
			
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
            if(code == houseCode.code){
                User.save(houseCode.house, as: .house)
                User.save(houseCode.floorID, as: .floorID)
                User.save(0 as Any, as: .permissionLevel)
                User.save(0 as Any, as: .points)
                return true
            }
        }
        return false
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@purdue.edu"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func hasEmptyFields(emailOptional:String?, passwordOptional:String?, verifyPasswordOptional:String?, nameOptional:String?, codeOptional:String?) -> Bool{
        if let email = emailOptional, let password = passwordOptional, let verifyPassword = verifyPasswordOptional, let name = nameOptional, let code = codeOptional {
            
            return (email == "" || password == "" || verifyPassword == "" || name == "" || code == "" )
        }
        return false
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
