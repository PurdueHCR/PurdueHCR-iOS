//
//  QRCodeGeneratorViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class QRCodeGeneratorViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource, UITextViewDelegate {
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var multiUseSwitch: UISwitch!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var generateButton: UIButton!
    
    var appendMethod:((_ link:Link)->Void)?
    var pointTypes = [PointType]()
    var selectedPoint = DataManager.sharedManager.getPoints()![0]
    var link:Link?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pointTypes = filter(points: DataManager.sharedManager.getPoints()!)
        pickerView.reloadAllComponents()
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(0, inComponent: 0, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pointTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pointTypes[row].pointDescription
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedPoint = pointTypes[row]
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == "Enter point description here."){
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            textView.text = "Enter point description here."
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text.suffix(1) == "\n"){
            textView.text = textView.text.dropLast().description
            textView.resignFirstResponder()
        }
    }
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.descriptionTextView.resignFirstResponder()
    }
    @IBAction func generateQRCodes(_ sender: Any) {
        self.generateButton.isEnabled = false;
        if(descriptionTextView.text == "" || descriptionTextView.text == "Enter point description here."){
            notify(title: "Failed to create QR Code", subtitle: "Please enter a description of your event.", style: .danger)
            self.generateButton.isEnabled = true;
        }
        else {
            let link = Link(description: descriptionTextView.text, singleUse: !(multiUseSwitch.isOn), pointTypeID: selectedPoint.pointID)
            DataManager.sharedManager.createQRCode(link: link, onDone: {(id:String?) in
                guard let linkID = id else{
                    self.notify(title: "Failure", subtitle: "Could not create QR Code", style: .danger)
                    self.generateButton.isEnabled = true;
                    return
                }
                link.id = linkID
                self.link = link
                self.appendMethod!(link)
                self.performSegue(withIdentifier: "QR_Generate", sender: self)
            })
        }
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "QR_Generate"){
            let nextViewController = segue.destination as! LinkCodeViewController
            nextViewController.link = self.link
        }
        
    }
    
    func filter(points:[PointType]) -> [PointType] {
        var types = [PointType]()
        let permissionLevel = User.get(.permissionLevel) as! Int
        for point in points {
            // Permission Level 2 is REA/REC, then check if point is enabled, then check RHP/FHP permission
			if( permissionLevel == 2 || (point.isEnabled && checkPermission(typePermission: point.permissionLevel.rawValue, userPermission: permissionLevel))){
                types.append(point)
            }
        }
        return types
    }
    //Check permission Level when USER is not REA/REC
    private func checkPermission(typePermission:Int, userPermission:Int) ->Bool {
        return ((userPermission == 1 && typePermission != 1) || (userPermission == 3 && typePermission == 3))
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        if(sender.isOn){
            let alert = UIAlertController(title: "Multi-Scan Enabled", message: "If you allow residents to scan this code multiple times, each submission will be sent for RHP approval before points are awarded.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
