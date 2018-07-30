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
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
        tableView.refreshControl = refresher
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resfreshData()
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
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
                self.notify(title: "Failed", subtitle: "Failed to remove point log.", style: .danger)
                self.unconfirmedLogs.append(log)
                DispatchQueue.main.async { [unowned self] in
                    self.tableView.reloadData()
                }
            }
            else{
                self.notify(title: "Success", subtitle: "Point Handled", style: .success)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "cell_push", sender: self)
        
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let nextViewController = segue.destination as! PointLogOverviewController
        let indexPath = tableView.indexPathForSelectedRow
        
        nextViewController.pointLog = self.unconfirmedLogs[(indexPath?.row)!]
        nextViewController.index = ( sender as! RHPApprovalTableViewController ).tableView.indexPathForSelectedRow
        nextViewController.preViewContr = self
    }

}
