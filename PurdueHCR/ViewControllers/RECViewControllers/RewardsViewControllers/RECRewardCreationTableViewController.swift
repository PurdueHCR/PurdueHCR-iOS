//
//  RECRewardCreationTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 11/6/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class RECRewardCreationTableViewController: UITableViewController {


    @IBOutlet var nameField: UITextField!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    var reward:Reward?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(reward == nil){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createReward))
        }
        else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateReward))
            nameField.text = reward!.rewardName
            valueField.text = reward!.requiredValue.description
            imageView.image = reward!.image!
        }
        
    }
    @IBAction func addImage(_ sender: Any) {
        print("Add Imag")
    }
    
    @objc func createReward(){
        print("Create Reward")
    }
    
    @objc func updateReward(){
        print("Update Reward")
    }
    
    

}
