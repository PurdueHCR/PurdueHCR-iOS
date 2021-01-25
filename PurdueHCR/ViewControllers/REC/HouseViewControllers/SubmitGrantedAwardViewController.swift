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
    @IBOutlet weak var pprField: UITextField!
    

    var house:House?
    
    let placeholder = "Give a description for the award!"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionField.layer.cornerRadius = DefinedValues.radius
        descriptionField.text = placeholder
        descriptionField.textColor = UIColor.lightGray
        descriptionField.selectedTextRange = descriptionField.textRange(from: descriptionField.beginningOfDocument, to: descriptionField.beginningOfDocument)
        
        self.navigationItem.title = ("Give Award to " + house!.houseID)
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
        guard let ppr = Int(pprField.text ?? "") else {
            notify(title: "Failure", subtitle: "Please provide a valid number for points per resident", style: .danger)
            return
        }
        if (ppr <= 0) {
            notify(title: "Failure", subtitle: "Please provide a valid number for points per resident", style: .danger)
            return
        }
        if (description == placeholder) {
            notify(title: "Failure", subtitle: "Please add an award description", style: .danger)
            return
        }
        self.submitButton.isEnabled = false
        grantAward(ppr: ppr, logDescription: description)
    }
    

    func grantAward(ppr: Int, logDescription: String) {
		
        DataManager.sharedManager.awardPointsToHouseFromREC(ppr: ppr, house: house!, description: logDescription) { (error) in
            if(error != nil) {
                print("Error in posting: ",error!.localizedDescription)
                self.submitButton.isEnabled = true
                return
            }
            else{
                self.navigationController?.popViewController(animated: true)
                self.notify(title: "Award Granted", subtitle: "\(self.pprField.text!) points given to \(self.house!.houseID) House.", style: .success)
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
