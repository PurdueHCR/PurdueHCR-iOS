//
//  RECRewardCreationTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 11/6/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class RECRewardCreationTableViewController: UITableViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {


    @IBOutlet var nameField: UITextField!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    var topBarButton : UIBarButtonItem?
    
    var reward:Reward?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.layer.cornerRadius = DefinedValues.radius
        valueField.layer.cornerRadius = DefinedValues.radius
        
        if(reward == nil){
            topBarButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createReward))
            self.navigationItem.rightBarButtonItem = topBarButton
        }
        else{
            topBarButton = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateReward))
            self.navigationItem.rightBarButtonItem = topBarButton
            nameField.text = reward!.rewardName
            valueField.text = reward!.requiredPPR.description
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .white
            imageView.image = reward!.image!.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
            imageView.layer.cornerRadius = 7
            
            
        }
        
        
    }
    @IBAction func addImage(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.accessibilityActivate()
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        imagePicker.dismiss(animated: true, completion: nil)
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imageView.image = image
        }
        
    }
    
    
    @objc func createReward(){
        topBarButton?.isEnabled = false
        
        guard let image = imageView.image else{
            self.notify(title: "Failure", subtitle: "Please add image", style: .danger)
            topBarButton?.isEnabled = true
            return
        }
        guard let rewardName = nameField.text , !rewardName.isEmpty else{
            self.notify(title: "Failure", subtitle: "Please add a name", style: .danger)
            topBarButton?.isEnabled = true
            return
        }
        guard let pointValue = valueField.text, !pointValue.isEmpty, let value = Int(pointValue) else{
            self.notify(title: "Failure", subtitle: "Pleade enter a number point value.", style: .danger)
            topBarButton?.isEnabled = true
            return
        }
        
        let reward = Reward(requiredPPR: value, fileName: Date().description + rewardName+".png", rewardName: rewardName, downloadURL: "", id: "")
        DataManager.sharedManager.createReward(reward: reward, image: image) { (error) in
            if(error == nil){
                self.notify(title: "Success", subtitle: "Reward Created", style: .success)
            }
            else{
                print("ERROR: ",error!.localizedDescription)
                if(error?.localizedDescription == "The operation couldn’t be completed. (Image is too large error 1.)"){
                    self.notify(title: "Failure", subtitle: "Image is too large.", style: .danger)
                }
                else{
                    self.notify(title: "Failure", subtitle: "Could not upload Reward.", style: .danger)
                }
                self.topBarButton?.isEnabled = true
            }
        }
    }
    

    @objc func updateReward() {
        topBarButton?.isEnabled = false
        
        guard let image = imageView.image else{
            self.notify(title: "Failure", subtitle: "Please add image", style: .danger)
            topBarButton?.isEnabled = true
            return
        }
        guard let rewardName = nameField.text , !rewardName.isEmpty else{
            self.notify(title: "Failure", subtitle: "Please add a name", style: .danger)
            topBarButton?.isEnabled = true
            return
        }
        guard let pointValue = valueField.text, !pointValue.isEmpty, let value = Int(pointValue) else{
            self.notify(title: "Failure", subtitle: "Pleade enter a number point value.", style: .danger)
            topBarButton?.isEnabled = true
            return
        }
        let oldName = reward!.fileName
        
        let reward = Reward(requiredPPR: value, fileName: Date().description + rewardName+".png", rewardName: rewardName, downloadURL: "", id:reward!.id)
        DataManager.sharedManager.updateReward(reward: reward, image: image, oldFilename: oldName) { (error) in
            if(error == nil){
            
            }
            else{
                self.notify(title: "Failure", subtitle: "Could not update", style: .danger)
            }
        }
    }
    

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
