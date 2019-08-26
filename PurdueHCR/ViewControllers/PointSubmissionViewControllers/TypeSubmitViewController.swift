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

class TypeSubmitViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {

    @IBOutlet var typeLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet var descriptionField: UITextView!
	@IBOutlet weak var houseImage: UIImageView!
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
	
    var type:PointType?
    var user:User?
    var fortyPercent = CGFloat(0.0)
    var lastChange = 0.0
	let placeholder = "Tell us what you did!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text? = type!.pointName
		typeLabel.sizeToFit()
		descriptionLabel.text = type!.pointDescription
		descriptionLabel.sizeToFit()
        descriptionLabel.textColor = UIColor.darkGray
        let firstName = User.get(.firstName) as! String
		let lastName = User.get(.lastName) as! String
		nameLabel.text = firstName + " " + lastName
		descriptionField.text = placeholder
		descriptionField.textColor = UIColor.lightGray
		descriptionField.selectedTextRange = descriptionField.textRange(from: descriptionField.beginningOfDocument, to: descriptionField.beginningOfDocument)
        descriptionField.layer.borderColor = UIColor.lightGray.cgColor
        descriptionField.layer.borderWidth = 1
		//descriptionField.becomeFirstResponder()
		submitButton.layer.cornerRadius = 10
		
        fortyPercent = self.view.frame.size.height * 0.45
        
		self.topView.layer.shadowColor = UIColor.darkGray.cgColor
		self.topView.layer.shadowOpacity = 0.5
		self.topView.layer.shadowOffset = CGSize.zero
		self.topView.layer.shadowRadius = 7
		self.topView.sizeToFit()
		
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
		let houseName = User.get(.house) as! String
		if(houseName == "Platinum"){
			houseImage.image = #imageLiteral(resourceName: "Platinum")
		}
		else if(houseName == "Copper"){
			houseImage.image = #imageLiteral(resourceName: "Copper")
		}
		else if(houseName == "Palladium"){
			houseImage.image = #imageLiteral(resourceName: "Palladium")
		}
		else if(houseName == "Silver"){
			houseImage.image = #imageLiteral(resourceName: "Silver")
		}
		else if(houseName == "Titanium"){
			houseImage.image = #imageLiteral(resourceName: "Titanium")
		}
		datePicker.maximumDate = Date()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func submit(_ sender: Any) {
        submitButton.isEnabled = false;
        guard let description = descriptionField.text, !description.isEmpty, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else{
            notify(title: "Failure", subtitle: "Please enter a description", style: .danger)
            submitButton.isEnabled = true;
            return
        }
        guard let pointType = type else{
            notify(title: "Failure", subtitle: "Please reselect your point type", style: .danger)
            submitButton.isEnabled = true;
            return
        }
        if(description == placeholder){
            notify(title: "Failure", subtitle: "Please tell us more about what you did!", style: .danger)
            submitButton.isEnabled = true;
            return
        }
        submitPointLog(pointType: pointType, logDescription: description)
    }
    
    
    /// Submit Point Log to DataHandler. 
    ///
    /// - Parameters:
    ///   - pointType: Point Type to have a log created of
    ///   - descriptions: String text describing what the residents did
    func submitPointLog(pointType:PointType, logDescription:String){
		
		// TODO: Update reported time of point
		
		let firstName = User.get(.firstName) as! String
		let lastName = User.get(.lastName) as! String
        let preApproved = ((User.get(.permissionLevel) as! Int) == 1)
        let floor = User.get(.floorID) as! String
		let residentId = User.get(.id) as! String
		
		let dateOccurred = Timestamp.init(date: datePicker.date)
        let pointLog = PointLog(pointDescription: logDescription, firstName: firstName, lastName: lastName, type: pointType, floorID: floor, residentId: residentId, dateOccurred: dateOccurred)
		DataManager.sharedManager.writePoints(log: pointLog, preApproved: preApproved) { (err:Error?) in
            if (err != nil) {
                if(err!.localizedDescription == "The operation couldn’t be completed. (Could not submit points because point type is disabled. error 1.)"){
                    self.notify(title: "Failed to submit", subtitle: "Point Type is no longer enabled.", style: .danger)
                }
                else{
                    self.notify(title: "Failed to submit", subtitle: "Database Error.", style: .danger)
                    print("Error in posting: ",err!.localizedDescription)
                }
                
                self.submitButton.isEnabled = true;
                return
            }
			
        }
		self.navigationController?.popViewController(animated: true)
		if(preApproved){
			self.notify(title: "Way to Go RHP", subtitle: "Congrats, \(pointLog.type.pointValue) points submitted.", style: .success)
		}
		else{
			self.notify(title: "Submitted for approval!", subtitle: pointLog.pointDescription, style: .success)
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
	
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.descriptionField.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        moveTextView(textView: self.descriptionField, up: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        moveTextView(textView: self.descriptionField, up: false)
    }
    
    func moveTextView(textView:UITextView, up:Bool){
        if(up && textView.frame.minY > self.fortyPercent){
            let movement = self.fortyPercent - textView.frame.minY
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
}
