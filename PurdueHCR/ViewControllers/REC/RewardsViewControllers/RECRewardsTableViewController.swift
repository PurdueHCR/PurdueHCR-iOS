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
    var refresher: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rewards = DataManager.sharedManager.getRewards()
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (rewards == nil){
            return 0
        }
        else{
            return rewards!.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reward_cell", for: indexPath) as! RewardCell

        // Configure the cell...
        cell.nameLabel.text = rewards![indexPath.row].rewardName
        cell.pointsLabel.text = rewards![indexPath.row].requiredPPR.description
        cell.rewardImageView.image = rewards![indexPath.row].image!
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            DataManager.sharedManager.deleteReward(reward: rewards![indexPath.row]) { (error) in
                if(error == nil){
                    self.rewards!.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.notify(title: "Success", subtitle: "Reward Deleted", style: .success)
                }
                else{
                    self.notify(title: "Failure", subtitle: "Could not delete", style: .danger)
                }
            }
            
            
            
        }
    }
    

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
    
    @objc func refreshData(){
        DataManager.sharedManager.refreshRewards { (rewards) in
            self.rewards = rewards
            DispatchQueue.main.async { [weak self] in
                if(self != nil){
                    self?.tableView.reloadData()
                }
            }
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    

}

class RewardCell:UITableViewCell{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var rewardImageView: UIImageView!
    @IBOutlet var pointsLabel: UILabel!
    
}
