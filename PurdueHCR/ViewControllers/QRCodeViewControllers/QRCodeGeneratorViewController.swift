//
//  QRCodeGeneratorViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class QRCodeGeneratorViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var selectPointType: UIButton!
    @IBOutlet var multiUseSwitch: UISwitch!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var generateButton: UIButton!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    var appendMethod:((_ link:Link)->Void)?
    static var pointTypes = [PointType]()
    static var pointTypesIndex = -1
    var link:Link?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        QRCodeGeneratorViewController.pointTypes = DataManager.filter(points: DataManager.sharedManager.getPoints()!)
        descriptionTextView.layer.cornerRadius = DefinedValues.radius
        descriptionTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    
        loadingIcon.isHidden = true
        loadingIcon.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (QRCodeGeneratorViewController.pointTypesIndex == -1) {
            selectPointType.setTitle("Select Point Type...", for: .normal)
        } else {
            selectPointType.setTitle(QRCodeGeneratorViewController.pointTypes[QRCodeGeneratorViewController.pointTypesIndex].pointName, for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        } else if (QRCodeGeneratorViewController.pointTypesIndex == -1) {
            notify(title: "Failed to create QR Code", subtitle: "Please select a point type.", style: .danger)
            self.generateButton.isEnabled = true;
        } else {
            DataManager.sharedManager.createQRCode(singleUse: !(multiUseSwitch.isOn), pointID: QRCodeGeneratorViewController.pointTypes[QRCodeGeneratorViewController.pointTypesIndex].pointID, description: descriptionTextView.text, isEnabled: true) { (code, err) in
                if (err != nil) {
                    print("Error: Unabled to create QR code. \(String(describing: err?.localizedDescription))")
                    self.generateButton.isEnabled = true
                    self.loadingIcon.stopAnimating()
                    self.loadingIcon.isHidden = true
                    return
                } else {
                    // set link and do this method....
                    self.link = Link(data: code!)
                    self.appendMethod?(self.link!)
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
        if (segue.destination is QRSelectPointTypeTableViewController) {
            let dest = segue.destination as! QRSelectPointTypeTableViewController
            dest.delegate = self
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
        return ((userPermission == PointType.PermissionLevel.rhp && typePermission >= 1) || (userPermission == PointType.PermissionLevel.priv && typePermission == 3) || (userPermission == PointType.PermissionLevel.faculty && typePermission == 3))
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        if(sender.isOn){
            let alert = UIAlertController(title: "Multi-Scan Enabled", message: "If you allow residents to scan this code multiple times, each submission will be sent for RHP approval before points are awarded.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


extension QRCodeGeneratorViewController: QRSelectPointTypeDelegate {    
    func updateQRPointTypeData(pointTypeSelected: Int) {
        print("In the extension")
        QRCodeGeneratorViewController.pointTypesIndex = pointTypeSelected
        print("New val: " + String(CreateEventTableViewController.pointTypesIndex))
    }
    
    // Sounds like this whole process can be simplified with this:
    // https://matteomanferdini.com/how-ios-view-controllers-communicate-with-each-other/#section3
    // Can be used for create event too if wanna do that.
    
}
