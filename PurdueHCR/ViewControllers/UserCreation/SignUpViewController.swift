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
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var verifyPasswordField: UITextField!
    @IBOutlet var signUpButton: UIButton!
	@IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    
    
    var fortyPercent = CGFloat(0.0)
    var lastChange = 0.0
    var houses:[House]?
    
    var uncheckedImage: UIImage?
    var checkedImage: UIImage?
    
    // For use when creating account from link
    static var houseCode:String?
    
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
        self.passwordField.delegate = self
        self.verifyPasswordField.delegate = self
		
        emailField.layer.cornerRadius = 10
        emailField.layer.masksToBounds = true
		emailField.backgroundColor = DefinedValues.systemGray5
        //emailField.layer.borderWidth = 1
        //emailField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.layer.cornerRadius = 10
        passwordField.layer.masksToBounds = true
		passwordField.backgroundColor = DefinedValues.systemGray5
        //passwordField.layer.borderWidth = 1
        //passwordField.layer.borderColor = UIColor.lightGray.cgColor
        verifyPasswordField.layer.cornerRadius = 10
        verifyPasswordField.layer.masksToBounds = true
		verifyPasswordField.backgroundColor = DefinedValues.systemGray5
        //verifyPasswordField.layer.borderWidth = 1
        //verifyPasswordField.layer.borderColor = UIColor.lightGray.cgColor
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        //signUpButton.layer.borderWidth = 1
        //signUpButton.layer.borderColor = UIColor.black.cgColor
        
        uncheckedImage = UIImage(named: "SF_circle_righthalf_fill")!.withRenderingMode(.alwaysTemplate)
        checkedImage = UIImage(named: "SF_checkmark")!.withRenderingMode(.alwaysTemplate)
        termsButton.setImage(uncheckedImage, for: .normal)
        termsButton.tintColor = DefinedValues.systemBlue
        privacyButton.setImage(uncheckedImage, for: .normal)
        privacyButton.tintColor = DefinedValues.systemBlue
        
        
    }
    
    @IBAction func submitSignUp(_ sender: Any) {
        self.signUpButton.isEnabled = false
        self.activityIndicator.startAnimating()
        let email = emailField.text
        let password = passwordField.text
        let verifyPassword = verifyPasswordField.text
        
        
        if( hasEmptyFields(emailOptional: email, passwordOptional: password, verifyPasswordOptional: verifyPassword)){
            self.notify(title: "Failed to Sign Up", subtitle: "Please enter all information.", style: .danger)
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
		else if (password?.split(separator: " ").count != 1) {
			self.notify(title: "Failed to Sign Up", subtitle: "Password contains invalid characters.", style: .danger)
			self.signUpButton.isEnabled = true
			self.activityIndicator.stopAnimating()
		}
        else if ( password! != verifyPassword){
            self.notify(title: "Failed to Sign Up", subtitle: "Please verify your passwords are the same.", style: .danger)
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
        else if ( !isValidEmail(testStr: email!)){
            self.notify(title: "Failed to Sign Up", subtitle: "Please enter a valid Purdue email address.", style: .danger)
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
        else if (termsButton.currentImage == uncheckedImage) {
            termsButton.tintColor = DefinedValues.systemRed
            self.signUpButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
        else if (privacyButton.currentImage == uncheckedImage) {
            privacyButton.tintColor = DefinedValues.systemRed
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
				User.save(user.uid, as: .id)
				self.performSegue(withIdentifier: "code_push", sender: self)
            }
			
		}
		
        
    }
	
	
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@purdue.edu"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func hasEmptyFields(emailOptional:String?, passwordOptional:String?, verifyPasswordOptional:String? ) -> Bool{
        if let email = emailOptional, let password = passwordOptional, let verifyPassword = verifyPasswordOptional {
            
            return (email == "" || password == "" || verifyPassword == "" )
        }
        return false
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Only to be used when signing up with code
    @objc func goToLogin() {
        self.performSegue(withIdentifier: "seg_back", sender: self)
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
    
    @IBAction func selectTerms(_ sender: Any) {
        if (termsButton.currentImage == uncheckedImage) {
            termsButton.tintColor = DefinedValues.systemBlue
            termsButton.setImage(checkedImage, for: .normal)
        } else {
            termsButton.setImage(uncheckedImage, for: .normal)
        }
    }
    
    @IBAction func selectPrivacyPolicy(_ sender: Any) {
        if (privacyButton.currentImage == uncheckedImage) {
            privacyButton.tintColor = DefinedValues.systemBlue
            privacyButton.setImage(checkedImage, for: .normal)
        } else {
            privacyButton.setImage(uncheckedImage, for: .normal)
        }
    }
    
    @IBAction func openTerms(_ sender: Any) {
        if let url = URL(string: "https://purduehcr.web.app/terms-and-conditions") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        if let url = URL(string: "https://purduehcr.web.app/privacy") {
            UIApplication.shared.open(url)
        }
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
