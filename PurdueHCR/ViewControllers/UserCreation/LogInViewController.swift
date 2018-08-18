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

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var logInButton: UIButton!
    
    var fortyPercent = CGFloat(0.0)
    var lastChange = 0.0
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(activityIndicator)
        
        
        self.username.delegate = self
        self.password.delegate = self
        fortyPercent = self.view.frame.size.height * CGFloat(0.4)
        username.layer.cornerRadius = 5
        username.layer.masksToBounds = true
        username.layer.borderWidth = 1
        username.layer.borderColor = UIColor.black.cgColor
        password.layer.cornerRadius = 5
        password.layer.masksToBounds = true
        password.layer.borderWidth = 1
        password.layer.borderColor = UIColor.black.cgColor
        logInButton.layer.cornerRadius = 5
        logInButton.layer.masksToBounds = true
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.black.cgColor
        
        // Do any additional setup after loading the view.
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
                self.notify(title: "Failed to Log In", subtitle: error!.localizedDescription, style: .danger)
                self.logInButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                return
            }
            //The DataManager will handle setting all the elements in User.properties
            DataManager.sharedManager.getUserWhenLogginIn(id: usr.user.uid, onDone: { (success:Bool) in
                if(success){
                    self.notify(title: "Success", subtitle: "Logging in", style: .success)
                    User.save(Auth.auth().currentUser?.uid as Any, as: .id)
                    Cely.changeStatus(to: .loggedIn)
                    self.activityIndicator.stopAnimating()
                }
                else{
                    self.logInButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    try! Auth.auth().signOut()
                    self.notify(title: "Error", subtitle: "Could not find user information. Please create a new account.", style: .danger)
                    return
                }
            })
        }
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
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField: textField, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        moveTextField(textField: textField, up: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
