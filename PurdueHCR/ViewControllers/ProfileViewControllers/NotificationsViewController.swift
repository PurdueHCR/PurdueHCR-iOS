//
//  NotificationsViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 8/3/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController, UISearchResultsUpdating {

	//let searchController = UISearchController(searchResultsController: nil)
	var filteredPoints = [PointLog]()
	var activityIndicator = UIActivityIndicatorView()
    var displayedLogs = [PointLog]()
    var refresher: UIRefreshControl?
	
	override func viewDidLoad() {
    
		//self.navigationItem.hidesBackButton = true
		self.activityIndicator.startAnimating()
		super.viewDidLoad()
		
		activityIndicator.center = self.view.center
		activityIndicator.style = .gray
		activityIndicator.hidesWhenStopped = true
		view.addSubview(activityIndicator)
		
		refresher = UIRefreshControl()
		refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
		tableView.refreshControl = refresher
		//searchController.searchResultsUpdater = self
		//searchController.obscuresBackgroundDuringPresentation = false
		//searchController.searchBar.placeholder = "Search Points"
		//navigationItem.searchController = searchController
		definesPresentationContext = true
	}
	
	@objc func resfreshData(){
		DataManager.sharedManager.getMessagesForUser(onDone: { (pointLogs:[PointLog]) in
			self.displayedLogs = pointLogs
			self.displayedLogs.sort(by: {$0.dateSubmitted!.dateValue() > $1.dateSubmitted!.dateValue()})
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
			self.tableView.refreshControl?.endRefreshing()
			self.activityIndicator.stopAnimating()
			self.navigationItem.hidesBackButton = false
		})
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if let index = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: index, animated: true)
		}
		resfreshData()
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
		else{
			if(displayedLogs.count > 0){
				killEmptyMessage()
				return 1
			}
			else {
				emptyMessage(message: "No notifications")
				navigationItem.searchController = nil
				return 0
			}
		}
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
		if(isFiltering()){
			if (filteredPoints[indexPath.row].wasRejected() == true) {
				cell.activeView.backgroundColor = DefinedValues.systemRed
			} else {
				cell.activeView.backgroundColor = DefinedValues.systemGreen
			}
			cell.descriptionLabel.text = filteredPoints[indexPath.row].pointDescription
			cell.reasonLabel.text = filteredPoints[indexPath.row].type.pointName
			cell.nameLabel.text = filteredPoints[indexPath.row].firstName + " " + filteredPoints[indexPath.row].lastName
		}
		else{
			if (displayedLogs[indexPath.row].wasRejected() == true) {
				cell.activeView.backgroundColor = DefinedValues.systemRed
			} else {
				cell.activeView.backgroundColor = DefinedValues.systemGreen
			}
			cell.reasonLabel?.text = displayedLogs[indexPath.row].type.pointName
			cell.nameLabel?.text = displayedLogs[indexPath.row].firstName + " " + displayedLogs[indexPath.row].lastName
			cell.descriptionLabel?.text = displayedLogs[indexPath.row].pointDescription
		}
		return cell
	}
	
    func updatePointLogStatus(log:PointLog, approve:Bool, updating:Bool = true, indexPath: IndexPath) {
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
						//self.tableView.setEditing(false, animated: true)
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
					}
				}
			}
		})
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Segue to the second view controlleh
        self.performSegue(withIdentifier: "notification_push", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// This function is called before the segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if (segue.identifier == "notification_push") {
			// get a reference to the second view controller
            let indexPath = tableView.indexPathForSelectedRow
			let nextViewController = segue.destination as! PointLogOverviewController
			
			if(isFiltering()) {
				nextViewController.pointLog = self.filteredPoints[(indexPath?.row)!]
			} else {
				nextViewController.pointLog = self.displayedLogs[(indexPath?.row)!]
			}
			nextViewController.preViewContr = self
			nextViewController.indexPath = indexPath
		}
	}
	
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return true//searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredPoints = displayedLogs.filter({( point : PointLog) -> Bool in
			let searched = searchText.lowercased()
			let inFirstName = point.firstName.lowercased().contains(searched)
			let inLastName = point.lastName.lowercased().contains(searched)
			let inReason = point.type.pointDescription.lowercased().contains(searched)
			let inDescription = point.pointDescription.lowercased().contains(searched)
			return (inFirstName || inLastName || inReason || inDescription)
		})
		tableView.reloadData()
	}
	
	func isFiltering() -> Bool {
        return false //searchController.isActive && !searchBarIsEmpty()
	}
	
}
