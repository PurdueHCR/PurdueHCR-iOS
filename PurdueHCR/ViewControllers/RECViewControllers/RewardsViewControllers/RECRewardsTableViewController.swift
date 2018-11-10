//
//  RECRewardsTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 11/6/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class RECRewardsTableViewController: UITableViewController {

    
    var rewards: [Reward]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rewards = DataManager.sharedManager.getRewards()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rewards!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reward_cell", for: indexPath) as! RewardCell

        // Configure the cell...
        cell.nameLabel.text = rewards![indexPath.row].rewardName
        cell.pointsLabel.text = rewards![indexPath.row].requiredValue.description
        cell.rewardImageView.image = rewards![indexPath.row].image!
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "reward_push", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "reward_push"){
            // get a reference to the second view controller
            let nextViewController = segue.destination as! RECRewardCreationTableViewController
            
            let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
            //        if(isFiltering()){
            //            nextViewController.type = filteredPoints[(indexPath?.row)!]
            //        }
            //        else{
            //            nextViewController.type = pointSystem[(indexPath?.section)!].points[(indexPath?.row)!]
            //        }
            nextViewController.reward = rewards![indexPath!.row]
        }
    }
    

}

class RewardCell:UITableViewCell{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var rewardImageView: UIImageView!
    @IBOutlet var pointsLabel: UILabel!
    
}
