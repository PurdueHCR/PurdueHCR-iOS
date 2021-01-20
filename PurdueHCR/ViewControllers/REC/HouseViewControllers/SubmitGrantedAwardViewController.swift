//
//  SubmitGrantedAwardViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 11/14/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import Firebase

class SubmitGrantedAwardViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var typeLabel: UILabel!
    
    var house:House?
    var type:PointType?
    
    let placeholder = "Give a description for the award!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text = type?.pointName
        descriptionField.layer.cornerRadius = DefinedValues.radius
        descriptionField.text = placeholder
        descriptionField.textColor = UIColor.lightGray
        descriptionField.selectedTextRange = descriptionField.textRange(from: descriptionField.beginningOfDocument, to: descriptionField.beginningOfDocument)
    }
    
    /// Submit Point Log as award
    ///
    /// - Parameters:
    ///   - pointType: Type to be submitted
    ///   - descriptions: Description given by the REA/REC for reason why they were granting them the points
    @IBAction func submitAward(_ sender: Any) {
        // display warning if empty description
        guard let description = descriptionField.text, !description.isEmpty, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            notify(title: "Failure", subtitle: "Please enter a description", style: .danger)
            return
        }
        guard let pointType = type else {
            notify(title: "Failure", subtitle: "Please reselect your point type", style: .danger)
            submitButton.isEnabled = true
            return
        }
        if (description == placeholder){
            notify(title: "Failure", subtitle: "Please tell us more about what you did!", style: .danger)
            submitButton.isEnabled = true
            return
        }
        self.submitButton.isEnabled = false
        submitPointLog(pointType: pointType, logDescription: description)
    }
    

    func submitPointLog(pointType: PointType, logDescription: String) {
		let firstName = User.get(.firstName) as! String
		let lastName = User.get(.lastName) as! String
		let residentId = User.get(.id) as! String
		
		let log = PointLog(pointDescription: logDescription, firstName: firstName, lastName: lastName, type: pointType, floorID: "Award", residentId: residentId, dateOccurred: Timestamp.init())
        DataManager.sharedManager.awardPointsToHouseFromREC(log: log, house: house!) { (error) in
            if(error != nil){
                if(error!.localizedDescription == "The operation couldn’t be completed. (Could not submit points because point type is disabled. error 1.)"){
                    self.notify(title: "Failed to submit", subtitle: "Point Type is no longer enabled.", style: .danger)
                }
                else{
                    self.notify(title: "Failed to submit", subtitle: "Database Error.", style: .danger)
                    print("Error in posting: ",error!.localizedDescription)
                }
                
                self.submitButton.isEnabled = true;
                return
            }
            else{
                self.navigationController?.popViewController(animated: true)
                self.notify(title: "Award Granted", subtitle: "\(log.type.pointValue) points given to \(self.house!.houseID) House.", style: .success)
            }
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = ""
        }

        return updatedText.count <= 240
    }
}
