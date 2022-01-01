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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
	
    var type:PointType?
    var user:User?
	let placeholder = "Tell us what you did!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text? = type!.pointName
		typeLabel.sizeToFit()
		descriptionLabel.text = type!.pointDescription
		descriptionLabel.sizeToFit()
        let firstName = User.get(.firstName) as! String
		let lastName = User.get(.lastName) as! String
		nameLabel.text = firstName + " " + lastName
		descriptionField.text = placeholder
		descriptionField.textColor = UIColor.lightGray
		descriptionField.selectedTextRange = descriptionField.textRange(from: descriptionField.beginningOfDocument, to: descriptionField.beginningOfDocument)
        
//        descriptionField.layer.borderColor = UIColor.lightGray.cgColor
//        descriptionField.layer.borderWidth = 1

//        if #available(iOS 13.0, *) {
//            descriptionField.backgroundColor = UIColor.systemGray5
//        } else {
//            // Fallback on earlier versions
//            descriptionField.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 239.0/255.0, alpha: 1.0)
//        }
        descriptionField.layer.cornerRadius = DefinedValues.radius
        
		//descriptionField.becomeFirstResponder()
        submitButton.layer.cornerRadius = submitButton.frame.height / 2
    
        
        // This top view was originally here so that we could have the shadow effect. Since this effect has been removed, the view should be removed
//		self.topView.layer.shadowColor = UIColor.darkGray.cgColor
//		self.topView.layer.shadowOpacity = 0.5
//		self.topView.layer.shadowOffset = .init(width: 0, height: 5)
//		self.topView.layer.shadowRadius = 3
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
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor.gray
        activityIndicator.isHidden = false
        guard let description = descriptionField.text, !description.isEmpty, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else{
            notify(title: "Failure", subtitle: "Please enter a description", style: .danger)
            submitButton.isEnabled = true
            submitButton.backgroundColor = self.view.tintColor
            activityIndicator.isHidden = true
            return
        }
        guard let pointType = type else{
            notify(title: "Failure", subtitle: "Please reselect your point type", style: .danger)
            submitButton.isEnabled = true
            submitButton.backgroundColor = self.view.tintColor
            activityIndicator.isHidden = true
            return
        }
        if (description == placeholder){
            notify(title: "Failure", subtitle: "Please tell us more about what you did!", style: .danger)
            submitButton.isEnabled = true
            submitButton.backgroundColor = self.view.tintColor
            activityIndicator.isHidden = true
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
        
        
        // Check if date is more than four weeks old
        var dateComponent = DateComponents()
        dateComponent.month = 0
        dateComponent.day = -29
        dateComponent.year = 0
        let pastDate = Calendar.current.date(byAdding: dateComponent, to: Date())!
        if (datePicker.date < pastDate) {
            self.notify(title: "Date Error", subtitle: "Points must be submitted within four weeks of occurring", style: .danger)
            self.submitButton.isEnabled = true
            self.submitButton.backgroundColor = self.view.tintColor
            self.activityIndicator.isHidden = true
            return
        }
        
        
        let dateOccurred = Timestamp.init(date: datePicker.date)
        
        let pointLog = PointLog(pointDescription: logDescription, firstName: firstName, lastName: lastName, type: pointType, floorID: floor, residentId: residentId, dateOccurred: dateOccurred)
		DataManager.sharedManager.writePoints(log: pointLog, preApproved: preApproved) { (err:Error?) in
            if (err != nil) {
                self.submitButton.isEnabled = true
                self.submitButton.backgroundColor = self.view.tintColor
                self.activityIndicator.isHidden = true
            } else {
                self.navigationController?.popViewController(animated: true)
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
            if #available(iOS 13.0, *) {
                textView.textColor = UIColor.label
            } else {
                textView.textColor = .black
            }
			textView.text = ""
		}

		return updatedText.count <= 240
	}
	
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.descriptionField.resignFirstResponder()
    }

    var hasMoved = false
    
    /// Runs when the keyboard will appear on the screen
    @objc func keyboardWillShow(notification: NSNotification) {
        // Check if the screen has already been shifted up
        if (!hasMoved) {
            // Get the size of the current keyboard
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                
                // Location of the top of the keyboard on the screen
                let height = self.view.frame.height - keyboardSize.height - tabBarController!.tabBar.frame.height
                // Check if keyboard is above the bottom of the text field
                if (self.descriptionField.frame.maxY > height) {
                    let diff = self.descriptionField.frame.maxY - height
                    // Move the view up
                    self.view.frame.origin.y -= (diff + 20)
                    hasMoved = true
                }
            }
        }
    }
    
    
    /// Runs when the keyboard will disappear from the screen
    @objc func keyboardWillHide(notification: NSNotification) {
        // Restore the view to it's normal location in case it has been
        //  pushed up to accommodate the keyboard
        self.view.frame.origin.y = 0
        hasMoved = false
    }
}
