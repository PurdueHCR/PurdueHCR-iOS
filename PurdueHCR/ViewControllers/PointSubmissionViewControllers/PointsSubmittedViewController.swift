//
//  PointsSubmittedViewController.swift
//  PurdueHCR
//
//  Created by Ben Hardin on 1/12/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import UIKit

class PointsSubmittedViewController: UITableViewController {

	var refresher: UIRefreshControl?
	var confirmedLogs = [PointLog]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		confirmedLogs = DataManager.sharedManager.getResolvedPointLogs() ?? [PointLog]()
		refresher = UIRefreshControl()
		refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
		tableView.refreshControl = refresher
	}
	
	override func viewWillAppear(_ animated: Bool) {
		resfreshData()
	}
	
	@objc func resfreshData(){
		DataManager.sharedManager.refreshResolvedPointLogs(onDone: { (pointLogs:[PointLog]) in
			self.confirmedLogs = pointLogs
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
		else if confirmedLogs.count > 0 {
			killEmptyMessage()
			return 1
		} else {
			emptyMessage(message: "You don't have any to approve. Good job!")
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return confirmedLogs.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ApprovalCell
		
		cell.reasonLabel?.text = confirmedLogs[indexPath.row].type.pointDescription
		cell.nameLabel?.text = confirmedLogs[indexPath.row].resident
		cell.descriptionLabel?.text = confirmedLogs[indexPath.row].pointDescription
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
			let log = self.confirmedLogs.remove(at: indexPath.row)
			self.handlePointApproval(log: log, approve: true)
			if(self.confirmedLogs.count == 0){
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
			let log = self.confirmedLogs.remove(at: indexPath.row)
			self.handlePointApproval(log: log, approve: false)
			if(self.confirmedLogs.count == 0){
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
	
	
	func handlePointApproval(log:PointLog, approve:Bool){
		DataManager.sharedManager.updatePointLogStatus(log: log, approved: approve, onDone: { (err: Error?) in
			if let error = err {
				if(error.localizedDescription == "The operation couldn’t be completed. (Document has already been approved error 1.)"){
					self.notify(title: "WARNING: ALREADY HANDLED", subtitle: "Check with other RHPs before continuing", style: .warning)
					//                    DispatchQueue.main.async {
					//                        self.resfreshData()
					//                    }
					return
				}
				else if( error.localizedDescription == "The operation couldn’t be completed. (Document does not exist error 2.)"){
					self.notify(title: "Failure", subtitle: "Document no longer exists.", style: .danger)
					//                    DispatchQueue.main.async {
					//                        self.resfreshData()
					//                    }
					return
				}
				else{
					self.notify(title: "Failed", subtitle: "Failed to remove point log.", style: .danger)
					self.confirmedLogs.append(log)
					DispatchQueue.main.async { [unowned self] in
						if(self.confirmedLogs.count == 0 && self.tableView.numberOfSections != 0){
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
		//self.performSegue(withIdentifier: "cell_push", sender: self)
		
	}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
