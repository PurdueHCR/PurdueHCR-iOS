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

class PointsSubmittedViewController: RHPApprovalTableViewController {

	//var refresher: UIRefreshControl?
	//var displayedLogs = [PointLog]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		displayedLogs = DataManager.sharedManager.getResolvedPointLogs() ?? [PointLog]()
		refresher = UIRefreshControl()
		refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
		tableView.refreshControl = refresher
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
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResolvedCell
		
		cell.reasonLabel?.text = displayedLogs[indexPath.row].type.pointDescription
		cell.nameLabel?.text = displayedLogs[indexPath.row].resident
		cell.descriptionLabel?.text = displayedLogs[indexPath.row].pointDescription
		cell.activeView.layer.cornerRadius = cell.activeView.frame.width / 2
		if (displayedLogs[indexPath.row].wasRejected() == true) {
			cell.activeView.backgroundColor = UIColor.red
		} else {
			cell.activeView.backgroundColor = UIColor.green
		}
		return cell
	}
	
	override func updatePointLogStatus(log:PointLog, approve:Bool, indexPath: IndexPath) {
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
						self.tableView.setEditing(false, animated: true)
						self.tableView.reloadRows(at: [indexPath], with: .automatic)
					}
				}
				else{
					self.notify(title: "Success", subtitle: "Point rejected", style: .success)
					DispatchQueue.main.async {
						self.tableView.setEditing(false, animated: true)
						self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
			
			nextViewController.pointLog = self.displayedLogs[(indexPath?.row)!]
			//nextViewController.index = ( sender as! RHPApprovalTableViewController ).tableView.indexPathForSelectedRow
			nextViewController.preViewContr = self
			nextViewController.indexPath = indexPath
		}
	}

}
