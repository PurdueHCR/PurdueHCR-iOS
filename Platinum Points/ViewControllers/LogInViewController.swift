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

class LogInViewController: UIViewController {

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func login(_ sender: Any) {
        guard let email = username.text, let password = password.text else {
            postErrorNotification(message: "Please enter all information.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard let usr = user, error == nil else {
                self.postErrorNotification(message: error!.localizedDescription)
                return
            }
            //The DataManager will handle setting all the elements in User.properties
            DataManager.sharedManager.getUserWhenLogginIn(id: usr.user.uid, onDone: { (success:Bool) in
                if(success){
                    User.save(Auth.auth().currentUser?.uid as Any, as: .id)
                    Cely.changeStatus(to: .loggedIn)
                }
                else{
                    fatalError("Something bad happend that should not have happend. Somehow you have an account without a corresponding entry in user table.")
                }
            })
        }
    }
    
    func postErrorNotification(message:String){
        let alert = UIAlertController(title: "Error in Sign Up", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }

}
