//
//  RECPointCreationTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 10/31/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class RECPointCreationTableViewController: UITableViewController, UITextViewDelegate{

    @IBOutlet var descriptionsTextView: UITextView!
    @IBOutlet var residentsCanSubmitSwitch: UISwitch!
    @IBOutlet var permissionLabel: UILabel!
    @IBOutlet var permissionSlider: UISlider!
    @IBOutlet var pointsField: UITextField!
    @IBOutlet var enabledSwitch: UISwitch!
    
    
    
    var type:PointType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionsTextView.layer.borderColor = UIColor.black.cgColor
        descriptionsTextView.layer.borderWidth = 1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        if(type == nil){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createPointType))
            setPermissionLevel(value: 2)
        }
        else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updatePointType))
            descriptionsTextView.text = type!.pointDescription
            residentsCanSubmitSwitch.isOn = type!.residentCanSubmit
            setPermissionLevel(value: abs(type!.permissionLevel))
            permissionSlider.value = Float(abs(type!.permissionLevel))
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
        //Check Description
        //Check value
        
        guard let description = descriptionsTextView.text, !description.isEmpty, description != "What is this point for?" else {
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
        
        let newType = PointType(pv: pointValue, pd: description, rcs: residentsCanSubmit, pid: 0, permissionLevel: permissionLevel, isEnabled:isEnabled)
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
        guard let description = descriptionsTextView.text, !description.isEmpty, description != "What is this point for?" else {
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
        
        type!.permissionLevel = permissionLevel
        type!.residentCanSubmit = residentsCanSubmit
        type!.pointValue = pointValue
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
        if(self.permissionSlider.value < 1.5){
             setPermissionLevel(value: 1)
        }
        else if(self.permissionSlider.value > 2.5){
            setPermissionLevel(value: 3)
        }
        else{
            setPermissionLevel(value: 2)
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
    

    
    func setPermissionLevel(value:Int){
        let recString = NSMutableAttributedString(string: "REA/RECs")
        recString.append(NSMutableAttributedString(string: "\nCan use to create QR codes.", attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12) ]))
        let rhpString = NSMutableAttributedString(string: "REA/REC/RHPs")
        rhpString.append(NSMutableAttributedString(string: "\nCan use to create QR codes.", attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12) ]))
        let facultyString = NSMutableAttributedString(string: "REA/REC/RHP/Faculty")
        facultyString.append(NSMutableAttributedString(string: "\nCan use to create QR codes.", attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12) ]))
        if(value == 1){
            permissionLabel.attributedText = recString
        }
        else if(value == 2){
            permissionLabel.attributedText = rhpString
        }
        else if(value == 3){
            permissionLabel.attributedText = facultyString
        }
        else{
            permissionLabel.text = "Could not find level"
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == "What is this point for?"){
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            textView.text = "What is this point for?"
        }
    }
    
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.descriptionsTextView.resignFirstResponder()
        self.pointsField.resignFirstResponder()
    }

}