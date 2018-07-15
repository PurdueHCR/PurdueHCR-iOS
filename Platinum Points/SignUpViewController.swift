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

class SignUpViewController: UIViewController {

    @IBOutlet var emailField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var verifyPasswordField: UITextField!
    @IBOutlet var codeField: UITextField!
    
    
    @IBAction func submitSignUp(_ sender: Any) {
        let email = emailField.text
        let password = passwordField.text
        let verifyPassword = verifyPasswordField.text
        let name = nameField.text
        let code = codeField.text
        
        if( hasErrors(emailOptional: email, passwordOptional: password, verifyPasswordOptional: verifyPassword, nameOptional: name, codeOptional: code)){
            postErrorNotification(message: "Not All Fields Are Correct. Please verify your information and try again.")
        }
        else if(!codeIsValid(code:code!)){
            postErrorNotification(message: "Code is Invalid. Please try again.")
        }
        else{
            // user is fine to authenticate
            
            Auth.auth().createUser(withEmail: email!, password: password!) { (authResult, error) in
                guard let user = authResult?.user, error == nil else {
                    self.postErrorNotification(message:error!.localizedDescription)
                    return
                }
               //they are signed in
                // find the house that their code matches and go to the database and create their user
                //
                User.save(name as Any, as: .name)
                User.save(user.uid, as: .id)
                DataManager.sharedManager.createUser(onDone: ({ (err:Error?) in
                    if err != nil {
                        self.postErrorNotification(message: "Failed to create user. Please try again later.")
                    } else {
                        Cely.changeStatus(to: .loggedIn)
                    }
                }))
            }
        }
        
        
    }
    
    
    // code is format [houseIdentifier:roomNumber]
    func codeIsValid(code:String)-> Bool{
        let roomRegEx = "[A-Z0-9a-z]+:[N,S][2-6][0-9]{3}[a-d]"
        let roomTest = NSPredicate(format:"SELF MATCHES %@",roomRegEx)
        if(roomTest.evaluate(with: code)){
            let codeParts = code.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            let houseID = codeParts[0]
            //let room = codeParts[1]
            if(houseID == "9bBnfSE3LW"){
                User.save("Platinum", as: .house)
                User.save("0", as: .permissionLevel)
                return true
            }
        }
        return false
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func hasErrors(emailOptional:String?, passwordOptional:String?, verifyPasswordOptional:String?, nameOptional:String?, codeOptional:String?) -> Bool{
        if let email = emailOptional, let password = passwordOptional, let verifyPassword = verifyPasswordOptional, let name = nameOptional, let code = codeOptional {
            
            if(email.isEmpty || password.isEmpty || verifyPassword.isEmpty ||
                name.isEmpty || code.isEmpty ){
                return true
            }
            else if( password != verifyPassword){
                return true
            }
            else if( !isValidEmail(testStr: email)){
                return true
            }
            else{
                return false
            }
            
        }
        return true
    }
    
    func postErrorNotification(message:String){
        let alert = UIAlertController(title: "Error in Sign Up", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
