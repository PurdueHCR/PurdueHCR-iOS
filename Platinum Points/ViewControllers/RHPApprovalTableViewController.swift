//
//  RHPApprovalTableViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/15/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class ApprovalCell: UITableViewCell {
    @IBOutlet var reasonLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
}

class RHPApprovalTableViewController: UITableViewController {
    
    var refresher: UIRefreshControl?
    var unconfirmedLogs = [PointLog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unconfirmedLogs = DataManager.sharedManager.getUnconfirmedPointLogs() ?? [PointLog]()
        resfreshData()
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
        tableView.refreshControl = refresher
    }
    
    @objc func resfreshData(){
        DataManager.sharedManager.refreshUnconfirmedPointLogs(onDone: { (pointLogs:[PointLog]) in
            self.unconfirmedLogs = pointLogs
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
            self.tableView.refreshControl?.endRefreshing()
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return unconfirmedLogs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ApprovalCell
        
        cell.reasonLabel?.text = unconfirmedLogs[indexPath.row].type.pointDescription
        cell.nameLabel?.text = unconfirmedLogs[indexPath.row].resident

        return cell
    }
 


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let approve = UITableViewRowAction(style: .normal, title: "Approve") { action, index in
            print("Approve button tapped")
            let log = self.unconfirmedLogs.remove(at: index.row)
            self.handlePointApproval(log: log, approve: true)
            self.tableView.deleteRows(at: [index], with: .automatic)
        }
        approve.backgroundColor = .green
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("Delete button tapped")
            let log = self.unconfirmedLogs.remove(at: index.row)
            self.handlePointApproval(log: log, approve: false)
            self.tableView.deleteRows(at: [index], with: .automatic)
        }
        delete.backgroundColor = .red
        
        return [approve, delete]
    }
    
    
    func handlePointApproval(log:PointLog, approve:Bool){
        DataManager.sharedManager.confirmOrDenyPoints(log: log, approved: approve, onDone: { (err: Error?) in
            if(err != nil){
                print("Failed to handle log")
                self.unconfirmedLogs.append(log)
                DispatchQueue.main.async { [unowned self] in
                    self.tableView.reloadData()
                }
            }
        })
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
