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
    @IBOutlet var descriptionLabel: UILabel!
}

class RHPApprovalTableViewController: UITableViewController {
    
    var refresher: UIRefreshControl?
    var displayedLogs = [PointLog]()
	var index: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayedLogs = DataManager.sharedManager.getUnconfirmedPointLogs() ?? [PointLog]()
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
            self.displayedLogs = pointLogs
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
		if (!DataManager.sharedManager.systemPreferences!.isHouseEnabled) {
			let message = DataManager.sharedManager.systemPreferences!.houseEnabledMessage
			emptyMessage(message: message)
			return 0
		}
        else if displayedLogs.count > 0 {
            killEmptyMessage()
            return 1
        } else {
            emptyMessage(message: "You don't have any to approve. Good job!")
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return displayedLogs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ApprovalCell
        
        cell.reasonLabel?.text = displayedLogs[indexPath.row].type.pointDescription
        cell.nameLabel?.text = displayedLogs[indexPath.row].resident
        cell.descriptionLabel?.text = displayedLogs[indexPath.row].pointDescription

        return cell
    }
 


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let approveAction = UIContextualAction(style: .normal, title:  "Approve", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Approve button tapped")
            let log = self.displayedLogs.remove(at: indexPath.row)
            self.updatePointLogStatus(log: log, approve: true)
            if(self.displayedLogs.count == 0){
                let indexSet = NSMutableIndexSet()
                indexSet.add(0)
                self.tableView.deleteSections(indexSet as IndexSet, with: .automatic)
                success(true)
            }
            else{
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                success(true)
            }
            
        })
        approveAction.backgroundColor = .green
        approveAction.title = "Approve"
        return UISwipeActionsConfiguration(actions: [approveAction])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let rejectAction = UIContextualAction(style: .normal, title:  "Reject", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Delete button tapped")
            let log = self.displayedLogs.remove(at: indexPath.row)
            self.updatePointLogStatus(log: log, approve: false)
            if(self.displayedLogs.count == 0){
                let indexSet = NSMutableIndexSet()
                indexSet.add(0)
                self.tableView.deleteSections(indexSet as IndexSet, with: .automatic)
                success(true)
            }
            else{
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                success(true)
            }
        })
        rejectAction.backgroundColor = .red
        rejectAction.title = "Reject"
        return UISwipeActionsConfiguration(actions: [rejectAction])
    }
    
    
    func updatePointLogStatus(log:PointLog, approve:Bool) {
        DataManager.sharedManager.updatePointLogStatus(log: log, approved: approve, onDone: { (err: Error?) in
            if let error = err {
                if(error.localizedDescription == "The operation couldn’t be completed. (Point request has already been handled error 1.)"){
                    self.notify(title: "WARNING: ALREADY HANDLED", subtitle: "Check with other RHPs before continuing", style: .warning)
//                    DispatchQueue.main.async {
//                        self.resfreshData()
//                    }
                    return
                }
                else if( error.localizedDescription == "The operation couldn’t be completed. (Document does not exist error 2.)"){
                    self.notify(title: "Failure", subtitle: "Point request no longer exists.", style: .danger)
//                    DispatchQueue.main.async {
//                        self.resfreshData()
//                    }
                    return
                }
                else{
                    self.notify(title: "Failed", subtitle: "Failed to update point request.", style: .danger)
                    self.displayedLogs.append(log)
                    DispatchQueue.main.async { [unowned self] in
                        if(self.displayedLogs.count == 0 && self.tableView.numberOfSections != 0){
                            let indexSet = NSMutableIndexSet()
                            indexSet.add(0)
                            self.tableView.deleteSections(indexSet as IndexSet, with: .automatic)
                        }
                        self.tableView.reloadData()
                    }
                }
                
            }
            else{
                if(approve){
                    self.notify(title: "Success", subtitle: "Point approved", style: .success)
                }
                else{
                    self.notify(title: "Success", subtitle: "Point rejected", style: .success)
                }
                //self.resfreshData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "cell_push", sender: self)
        
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "cell_push") {
            // get a reference to the second view controller
            let nextViewController = segue.destination as! PointLogOverviewController
            let indexPath = tableView.indexPathForSelectedRow
            
            nextViewController.pointLog = self.displayedLogs[(indexPath?.row)!]
            index = ( sender as! RHPApprovalTableViewController ).tableView.indexPathForSelectedRow
            nextViewController.preViewContr = self
        }
    }

}
