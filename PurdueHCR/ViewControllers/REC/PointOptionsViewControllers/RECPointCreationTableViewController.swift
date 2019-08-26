//
//  RECPointCreationTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 10/31/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class RECPointCreationTableViewController: UITableViewController, UITextViewDelegate{

    @IBOutlet var nameTextView: UITextView!
    @IBOutlet var residentsCanSubmitSwitch: UISwitch!
    @IBOutlet var permissionLabel: UILabel!
    @IBOutlet var permissionSlider: UISlider!
    @IBOutlet var pointsField: UITextField!
    @IBOutlet var enabledSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    
    var type:PointType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextView.layer.borderColor = UIColor.lightGray.cgColor
        nameTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        if(type == nil){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createPointType))
            setPermissionLevel(value: PointType.PermissionLevel.rec)
        }
        else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updatePointType))
            nameTextView.text = type!.pointDescription
            residentsCanSubmitSwitch.isOn = type!.residentCanSubmit
            setPermissionLevel(value: type!.permissionLevel)
            permissionSlider.value = Float(abs(type!.permissionLevel.rawValue))
            enabledSwitch.isOn = type!.isEnabled
            pointsField.text = type!.pointValue.description
            
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let view = UIView()
        self.tableView.tableFooterView = view
    }
    
    @objc func createPointType() {
        // Check Name
        // Check Description
        // Check value
        
        guard let name = nameTextView.text, !name.isEmpty, name != "What is this point for?" else {
            self.notify(title: "Failure", subtitle: "Please add a name", style: .danger)
            return
        }
        guard let description = descriptionTextView.text, !description.isEmpty, description != "What is this point for?" else {
            self.notify(title: "Failure", subtitle: "Please add a description", style: .danger)
            return
        }
        guard let points = pointsField.text, !points.isEmpty, let pointValue = Int(points) else{
            self.notify(title: "Failure", subtitle: "Please add a point value", style: .danger)
            return
        }
        let residentsCanSubmit = residentsCanSubmitSwitch.isOn
        let permissionLevel = PointType.PermissionLevel(rawValue: Int(permissionSlider.value))!
        let isEnabled = enabledSwitch.isOn
		
		let newType = PointType(pv: pointValue, pn: name, pd: description, rcs: residentsCanSubmit, pid: 0, permissionLevel: permissionLevel, isEnabled:isEnabled)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        DataManager.sharedManager.createPointType(pointType: newType) { (error) in
            if(error == nil){
                self.navigationController?.popViewController(animated: true)
                self.notify(title: "Success", subtitle: "Point Type Created", style: .success)
            }
            else{
                self.notify(title: "Error", subtitle: "Database errpr", style: .danger)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    @objc func updatePointType(){
        guard let name = nameTextView.text, !name.isEmpty, name != "What do you want to call this point?" else {
            self.notify(title: "Failure", subtitle: "Please add a name", style: .danger)
            return
        }
        guard let description = descriptionTextView.text, !description.isEmpty, description != "What is this point for?" else {
            self.notify(title: "Failure", subtitle: "Please add a description", style: .danger)
            return
        }
        guard let points = pointsField.text, !points.isEmpty, let pointValue = Int(points) else{
            self.notify(title: "Failure", subtitle: "Please add a point value", style: .danger)
            return
        }
        let residentsCanSubmit = residentsCanSubmitSwitch.isOn
        let permissionLevel = Int(permissionSlider.value)
        let isEnabled = enabledSwitch.isOn
        
		type!.permissionLevel = PointType.PermissionLevel(rawValue: permissionLevel)!
        type!.residentCanSubmit = residentsCanSubmit
        type!.pointValue = pointValue
        type!.pointName = name
        type!.pointDescription = description
        type!.isEnabled = isEnabled
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        DataManager.sharedManager.updatePointType(pointType: type!) { (error) in
            if(error == nil){
                self.navigationController?.popViewController(animated: true)
                self.notify(title: "Success", subtitle: "Point Type Updated", style: .success)
            }
            else{
                self.notify(title: "Error", subtitle: "Database errpr", style: .danger)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        if (self.permissionSlider.value <= 0.5) {
			setPermissionLevel(value: .resident)
        }
		else if ((self.permissionSlider.value > 0.5) && (self.permissionSlider.value <= 1.5)) {
			setPermissionLevel(value: .rhp)
		}
		else if ((self.permissionSlider.value > 1.5) && (self.permissionSlider.value <= 2.5)) {
			setPermissionLevel(value: .rec)
		}
        else if(self.permissionSlider.value > 2.5){
            setPermissionLevel(value: .fhp)
        }

    }
    
    @IBAction func editingEnd(_ sender: Any) {
        if(self.permissionSlider.value < 1.5){
            self.permissionSlider.value = 1
        }
        else if(self.permissionSlider.value > 2.5){
            self.permissionSlider.value = 3
        }
        else{
            self.permissionSlider.value = 2
        }
    }
    

    
    func setPermissionLevel(value:PointType.PermissionLevel){
        let recString = NSMutableAttributedString(string: "REA/RECs")
        recString.append(NSMutableAttributedString(string: "\nCan use to create QR codes.", attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12) ]))
        let rhpString = NSMutableAttributedString(string: "REA/REC/RHPs")
        rhpString.append(NSMutableAttributedString(string: "\nCan use to create QR codes.", attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12) ]))
        let facultyString = NSMutableAttributedString(string: "REA/REC/RHP/Faculty")
        facultyString.append(NSMutableAttributedString(string: "\nCan use to create QR codes.", attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12) ]))
		if(value == PointType.PermissionLevel.rec){
            permissionLabel.attributedText = recString
        }
        else if(value == PointType.PermissionLevel.rhp){
            permissionLabel.attributedText = rhpString
        }
        else if(value == PointType.PermissionLevel.fhp){
            permissionLabel.attributedText = facultyString
        }
        else{
            permissionLabel.text = "Could not find level"
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == nameTextView) {
            if(textView.text == "What do you want to call this point?"){
                textView.text = ""
            }
        } else if (textView == descriptionTextView) {
            if(textView.text == "What is this point for?"){
                textView.text = ""
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView == nameTextView) {
            if(textView.text == ""){
                textView.text = "What do you want to call this point?"
            }
        } else if (textView == descriptionTextView) {
            if(textView.text == ""){
                textView.text = "What is this point for?"
            }
        }
    }
    
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.nameTextView.resignFirstResponder()
        self.pointsField.resignFirstResponder()
    }

}
