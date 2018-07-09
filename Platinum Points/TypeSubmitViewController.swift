//
//  TypeSubmitView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import ValueStepper

class TypeSubmitViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var countStepper: ValueStepper!
    @IBOutlet var descriptionField: UITextView!
    
    var typeName:String?
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text? = typeName!
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(_ sender: Any) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.text == "Please Enter A Description of What You Did"){
            textField.text = ""
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if(textField.text == ""){
            textField.text = "Please Enter A Description of What You Did"
        }
    }


/*    // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
}
