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
        
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
        
        if(reward == nil){
            topBarButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createReward))
            self.navigationItem.rightBarButtonItem = topBarButton
        }
        else{
            nameField.text = reward!.rewardName
            valueField.text = reward!.requiredValue.description
            imageView.image = reward!.image!
        }
        
        
    }
    @IBAction func addImage(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.accessibilityActivate()
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
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
        let reward = Reward(requiredValue: value, fileName: rewardName+".png", rewardName: rewardName)
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
    

    

}
