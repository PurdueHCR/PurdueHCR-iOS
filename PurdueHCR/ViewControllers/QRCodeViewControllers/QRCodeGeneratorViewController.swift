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
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    var appendMethod:((_ link:Link)->Void)?
    var pointTypes = [PointType]()
    var selectedPoint : PointType?// DataManager.sharedManager.getPoints()![0]
    var link:Link?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pointTypes = filter(points: DataManager.sharedManager.getPoints()!)
        pickerView.reloadAllComponents()
        selectedPoint = pointTypes[0]
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(0, inComponent: 0, animated: true)

        loadingIcon.isHidden = true
        loadingIcon.stopAnimating()

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
        return pointTypes[row].pointName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
        self.generateButton.isEnabled = false
        self.loadingIcon.startAnimating()
        self.loadingIcon.isHidden = false
        if (descriptionTextView.text == "" || descriptionTextView.text == "Enter point description here.") {
            notify(title: "Failed to create QR Code", subtitle: "Please enter a description of your event.", style: .danger)
            self.generateButton.isEnabled = true;
        } else {
            DataManager.sharedManager.createQRCode(singleUse: !(multiUseSwitch.isOn), pointID: selectedPoint!.pointID, description: descriptionTextView.text, isEnabled: true) { (code, err) in
                if (err != nil) {
                    print("Error: Unabled to create QR code. \(err?.localizedDescription)")
                    self.generateButton.isEnabled = true
                    self.loadingIcon.stopAnimating()
                    self.loadingIcon.isHidden = true
                    return
                } else {
                    // set link and do this method....
                    self.link = Link(data: code!)
                    self.appendMethod!(self.link!)
                    self.performSegue(withIdentifier: "QR_Generate", sender: self)
                }
                
            }
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
        let permissionLevel = PointType.PermissionLevel.init(rawValue: User.get(.permissionLevel) as! Int)!
        for point in points {
            // Permission Level 2 is REA/REC, then check if point is enabled, then check RHP/FHP permission
            if (permissionLevel == PointType.PermissionLevel.rec || (point.isEnabled && checkPermission(typePermission: point.permissionLevel.rawValue, userPermission: permissionLevel))) {
                types.append(point)
            }
        }
        return types
    }
    // Check permission Level when USER is not REA/REC
    private func checkPermission(typePermission:Int, userPermission:PointType.PermissionLevel) ->Bool {
        return (((userPermission == PointType.PermissionLevel.rhp || userPermission == PointType.PermissionLevel.priv) && typePermission != 1) || (userPermission == PointType.PermissionLevel.faculty && typePermission == 3))
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        if(sender.isOn){
            let alert = UIAlertController(title: "Multi-Scan Enabled", message: "If you allow residents to scan this code multiple times, each submission will be sent for RHP approval before points are awarded.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
