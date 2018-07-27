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
    
    var fortyPercent = CGFloat(0.0)
    var lastChange = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.delegate = self
        self.password.delegate = self
        fortyPercent = self.view.frame.size.height * CGFloat(0.4)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func login(_ sender: Any) {
        guard let email = username.text, let password = password.text else {
           self.notify(title: "Failed to Log In", subtitle: "Please enter all information.", style: .danger)
            return
        }
        if(email.isEmpty || password.isEmpty){
            self.notify(title: "Failed to Log In", subtitle: "Please enter all information.", style: .danger)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard let usr = user, error == nil else {
                self.notify(title: "Failed to Log In", subtitle: error!.localizedDescription, style: .danger)
                return
            }
            //The DataManager will handle setting all the elements in User.properties
            DataManager.sharedManager.getUserWhenLogginIn(id: usr.user.uid, onDone: { (success:Bool) in
                if(success){
                    self.notify(title: "Success", subtitle: "Logging in", style: .success)
                    User.save(Auth.auth().currentUser?.uid as Any, as: .id)
                    Cely.changeStatus(to: .loggedIn)
                }
                else{
                    fatalError("Something bad happend that should not have happend. Somehow you have an account without a corresponding entry in user table.")
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
