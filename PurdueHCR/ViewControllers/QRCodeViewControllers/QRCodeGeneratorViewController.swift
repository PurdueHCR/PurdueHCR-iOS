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
    let pointTypes = DataManager.sharedManager.getPoints()!
    var selectedPoint = DataManager.sharedManager.getPoints()![0]
    var link:Link?
    

    override func viewDidLoad() {
        super.viewDidLoad()
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
    

}
