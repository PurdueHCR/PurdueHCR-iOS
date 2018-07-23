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
    
    var type:PointType?
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text? = type!.pointDescription
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(_ sender: Any) {
        guard let description = descriptionField.text, !description.isEmpty else{
            print("Description is empty")
            return
        }
        let count = countStepper.value
        if ( count <= 0){
            print("Count is illegal number")
            return
        }
        guard let pointType = type else{
            print("PointType not found")
            return
        }
        
        let pointLog = PointLog(pointDescription: description, resident: User.get(.name) as! String, type: pointType, floorCode: User.get(.floorID) as! String)
        DataManager.sharedManager.writePoints(log: pointLog) { (err:Error?) in
            if(err != nil){
                self.postErrorNotification(message: err.debugDescription)
                print("Error in posting: ",err.debugDescription)
            }
            else{
                //post success
                print("Success")
                self.navigationController?.popViewController(animated: true)
            }
        }
        
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
    
    func postErrorNotification(message:String){
        let alert = UIAlertController(title: "Error in Submit", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }


/*    // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
}
