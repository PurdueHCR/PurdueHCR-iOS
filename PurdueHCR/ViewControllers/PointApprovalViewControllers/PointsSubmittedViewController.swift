//
//  PointsSubmittedViewController.swift
//  PurdueHCR
//
//  Created by Ben Hardin on 1/12/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import UIKit

class ResolvedCell: UITableViewCell {
	@IBOutlet weak var activeView: UIView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var reasonLabel: UILabel!
}

class PointsSubmittedViewController: RHPApprovalTableViewController, UISearchResultsUpdating {

	let searchController = UISearchController(searchResultsController: nil)
	var filteredPoints = [PointLog]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		displayedLogs = DataManager.sharedManager.getResolvedPointLogs() ?? [PointLog]()
		refresher = UIRefreshControl()
		refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
		tableView.refreshControl = refresher
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Points"
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}
	
	@objc override func resfreshData(){
		DataManager.sharedManager.refreshResolvedPointLogs(onDone: { (pointLogs:[PointLog]) in
			self.displayedLogs = pointLogs
			DispatchQueue.main.async { [unowned self] in
				self.tableView.reloadData()
			}
			self.tableView.refreshControl?.endRefreshing()
		})
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		if isFiltering() {
			if(filteredPoints.count > 0){
				killEmptyMessage()
				return 1
			}
			else {
				emptyMessage(message: "Could not find points matching that description.")
				return 0
			}
		}
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		if (isFiltering()) {
			return filteredPoints.count
		}
		return displayedLogs.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResolvedCell
		cell.activeView.layer.cornerRadius = cell.activeView.frame.width / 2
		if (displayedLogs[indexPath.row].wasRejected() == true) {
			cell.activeView.backgroundColor = UIColor.red
		} else {
			cell.activeView.backgroundColor = UIColor.green
		}
		if(isFiltering()){
			cell.descriptionLabel.text = filteredPoints[indexPath.row].pointDescription
			cell.reasonLabel.text = filteredPoints[indexPath.row].type.pointDescription
			cell.nameLabel.text = filteredPoints[indexPath.row].resident
		}
		else{
			cell.reasonLabel?.text = displayedLogs[indexPath.row].type.pointDescription
			cell.nameLabel?.text = displayedLogs[indexPath.row].resident
			cell.descriptionLabel?.text = displayedLogs[indexPath.row].pointDescription
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		var action : [UIContextualAction] = []
		let logs = self.displayedLogs[indexPath.row]
		if ((logs.wasHandled && logs.wasRejected()) || (!logs.wasHandled && !logs.wasRejected())) {
			let approveAction = UIContextualAction(style: .normal, title:  "Approve", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
				let log = self.displayedLogs[indexPath.row]
				self.updatePointLogStatus(log: log, approve: true, updating: true, indexPath: indexPath)
				if(self.displayedLogs.count == 0){
					let indexSet = NSMutableIndexSet()
					indexSet.add(0)
					success(true)
				}
				else{
					success(true)
				}
				
			})
			approveAction.backgroundColor = .green
			approveAction.title = "Approve"
			action.append(approveAction)
		}
		return UISwipeActionsConfiguration(actions: action)
	}
	
	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		var action : [UIContextualAction] = []
		let logs = self.displayedLogs[indexPath.row]
		if (!logs.wasRejected()) {
			let rejectAction = UIContextualAction(style: .normal, title:  "Reject", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
				let log = self.displayedLogs[indexPath.row]
				self.updatePointLogStatus(log: log, approve: false, updating: true, indexPath: indexPath)
				if(self.displayedLogs.count == 0){
					let indexSet = NSMutableIndexSet()
					indexSet.add(0)
					success(true)
				}
				else{
					success(true)
				}
			})
			rejectAction.backgroundColor = .red
			rejectAction.title = "Reject"
			action.append(rejectAction)
		}
		return UISwipeActionsConfiguration(actions: action)
	}
	
	override func updatePointLogStatus(log:PointLog, approve:Bool, updating:Bool = true, indexPath: IndexPath) {
		DataManager.sharedManager.updatePointLogStatus(log: log, approved: approve, updating: true, onDone: { (err: Error?) in
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
				else if (error.localizedDescription == "The operation couldn’t be completed. (Point request was already changed. error 1.)"){
					self.notify(title: "Failure", subtitle: "Point has already been updated.", style: .warning)
					return
				}
				else {
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
					DispatchQueue.main.async {
                        
                        //This is a work around because sometimes when transistioning back from PointLogOverviewViewController, the
                        //cell would not update the value properly. Even though it should be getting set already, we are doing in again.
                        if(self.isFiltering()){
                            self.filteredPoints[indexPath.row].updateApprovalStatus(approved: approve)
                        }
                        else{
                            self.displayedLogs[indexPath.row].updateApprovalStatus(approved: approve)
                        }
                        
						self.tableView.setEditing(false, animated: true)
						self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }
				}
				else{
					self.notify(title: "Success", subtitle: "Point rejected", style: .success)
					DispatchQueue.main.async {
                        
                        //This is a work around because sometimes when transistioning back from PointLogOverviewViewController, the
                        //cell would not update the value properly. Even though it should be getting set already, we are doing in again.
                        if(self.isFiltering()){
                            self.filteredPoints[indexPath.row].updateApprovalStatus(approved: approve)
                        }
                        else{
                            self.displayedLogs[indexPath.row].updateApprovalStatus(approved: approve)
                        }
                        
						self.tableView.setEditing(false, animated: true)
						self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }
				}
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
			
			if(isFiltering()) {
				nextViewController.pointLog = self.filteredPoints[(indexPath?.row)!]
			} else {
				nextViewController.pointLog = self.displayedLogs[(indexPath?.row)!]
			}
			nextViewController.preViewContr = self
			nextViewController.indexPath = indexPath
		}
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredPoints = displayedLogs.filter({( point : PointLog) -> Bool in
			let searched = searchText.lowercased()
			let inName = point.resident.lowercased().contains(searched)
			let inReason = point.type.pointDescription.lowercased().contains(searched)
			let inDescription = point.pointDescription.lowercased().contains(searched)
			return (inName || inReason || inDescription)
		})
		tableView.reloadData()
	}
	func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}

}
