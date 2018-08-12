//
//  TypeSubmitView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import ValueStepper
import Firebase

class TypeSubmitViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var descriptionField: UITextView!
    
    var type:PointType?
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text? = type!.pointDescription
        descriptionField.layer.borderColor = UIColor.black.cgColor
        descriptionField.layer.borderWidth = 1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(_ sender: Any) {
        guard let description = descriptionField.text, !description.isEmpty else{
            notify(title: "Failure", subtitle: "Please enter a description", style: .danger)
            return
        }
        guard let pointType = type else{
            notify(title: "Failure", subtitle: "Please reselect your point type", style: .danger)
            return
        }
        if(description == "Tell us about what you did!"){
            notify(title: "Failure", subtitle: "Please tell us more about what you did!", style: .danger)
            return
        }
        let name = User.get(.name) as! String
        let preApproved = ((User.get(.permissionLevel) as! Int) == 1 )
        let floor = User.get(.floorID) as! String
        let residentRef = DataManager.sharedManager.getUserRefFromUserID(id: User.get(.id) as! String)
        let pointLog = PointLog(pointDescription: description, resident: name, type: pointType, floorID: floor, residentRef:residentRef)
        DataManager.sharedManager.writePoints(log: pointLog, preApproved: preApproved) { (err:Error?) in
            if(err != nil){
                self.notify(title: "Failed to submit", subtitle: err.debugDescription, style: .danger)
                print("Error in posting: ",err.debugDescription)
            }
            else{
                self.navigationController?.popViewController(animated: true)
                if(preApproved){
                    self.notify(title: "Way to Go RHP", subtitle: "Congrats, \(pointLog.type.pointValue) points submitted.", style: .success)
                }
                else{
                    self.notify(title: "Success", subtitle: "\(pointLog.type.pointValue) points were submitted for approval.", style: .success)
                }
            }
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == "Tell us about what you did!"){
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            textView.text = "Tell us about what you did!"
        }
    }


    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.descriptionField.resignFirstResponder()
    }
/*    // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
}
