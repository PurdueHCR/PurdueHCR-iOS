//
//  PointsSubmittedViewController.swift
//  PurdueHCR
//
//  Created by Ben Hardin on 1/12/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import UIKit
import PopupKit

class ResolvedCell: UITableViewCell {
	@IBOutlet weak var activeView: UIView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
}

class HousePointsHistoryViewController: UITableViewController, UISearchResultsUpdating {
	
	let searchController = UISearchController(searchResultsController: nil)
	var filteredPoints = [PointLog]()
	var activityIndicator = UIActivityIndicatorView()
    var displayedLogs = [PointLog]()
    var refresher: UIRefreshControl?
    
    var sortDateSubmitted = true
    var sortDescending = true
    
    var p : PopupView?
	
	override func viewDidLoad() {
        
		//self.navigationItem.hidesBackButton = true
        self.navigationItem.largeTitleDisplayMode = .never
        
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
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Points"
		navigationItem.searchController = searchController
		definesPresentationContext = true
        resfreshData()
	}
	
	@objc func resfreshData(){
        DataManager.sharedManager.refreshResolvedPointLogs(onDone: { (pointLogs:[PointLog]) in
            
            self.displayedLogs = pointLogs
            self.performSort(sortByDateSubmitted: self.sortDateSubmitted, sortAscending: self.sortDescending)
            
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
                self.refresher?.endRefreshing()
            }
            self.tableView.refreshControl?.endRefreshing()
            self.activityIndicator.stopAnimating()
            self.navigationItem.hidesBackButton = false
        })
	}
    
    func performSort(sortByDateSubmitted: Bool, sortAscending: Bool) {
        if (sortByDateSubmitted) {
            if (sortAscending) {
                self.displayedLogs.sort(by: {$0.dateSubmitted!.dateValue() > $1.dateSubmitted!.dateValue()})
            } else {
                self.displayedLogs.sort(by: {$0.dateSubmitted!.dateValue() < $1.dateSubmitted!.dateValue()})
            }
        } else {
            if (sortAscending) {
                self.displayedLogs.sort(by: {$0.dateOccurred!.dateValue() > $1.dateOccurred!.dateValue()})
            } else {
                self.displayedLogs.sort(by: {$0.dateOccurred!.dateValue() < $1.dateOccurred!.dateValue()})
            }
            
        }
        
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
                emptyMessage(message: "No Point History")
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
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
		if(isFiltering()){
            if (filteredPoints[indexPath.row].wasRejected() == true) {
                cell.activeView.backgroundColor = DefinedValues.systemRed
            } else {
                cell.activeView.backgroundColor = DefinedValues.systemGreen
            }
            let point = filteredPoints[indexPath.row]
			cell.descriptionLabel.text = point.pointDescription
			cell.reasonLabel.text = point.type.pointName
			cell.nameLabel.text = point.firstName + " " + point.lastName
            
            cell.monthLabel.text = monthFormatter.string(from: point.dateSubmitted!.dateValue())
            cell.dayLabel.text = dayFormatter.string(from: point.dateSubmitted!.dateValue())
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            cell.monthLabel.text = dateFormatter.string(from: displayedLogs[indexPath.row].dateSubmitted!.dateValue())
            cell.dayLabel.text = dayFormatter.string(from: displayedLogs[indexPath.row].dateSubmitted!.dateValue())
		}
		return cell
	}
	
	/*override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		var action : [UIContextualAction] = []
        var log : PointLog
        if (isFiltering()) {
            log = self.filteredPoints[indexPath.row]
        } else {
            log = self.displayedLogs[indexPath.row]
        }
		if ((log.wasHandled && log.wasRejected()) || (!log.wasHandled && !log.wasRejected())) {
			let approveAction = UIContextualAction(style: .normal, title:  "Approve", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
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
			approveAction.backgroundColor = DefinedValues.green
			approveAction.title = "Approve"
			action.append(approveAction)
		}
		return UISwipeActionsConfiguration(actions: action)
	}
	
	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		var action : [UIContextualAction] = []
        var log : PointLog
        if (isFiltering()) {
            log = self.filteredPoints[indexPath.row]
        } else {
            log = self.displayedLogs[indexPath.row]
        }
		if (!log.wasRejected()) {
			let rejectAction = UIContextualAction(style: .normal, title:  "Reject", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
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
	} */
	
    func updatePointLogStatus(log:PointLog, approve:Bool, message:String = "", updating:Bool = true, indexPath: IndexPath) {
        DataManager.sharedManager.updatePointLogStatus(log: log, approved: approve, message: message, updating: true, onDone: { (err: Error?) in
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
		self.tableView.deselectRow(at: indexPath, animated: true)
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
			let inFirstName = point.firstName.lowercased().contains(searched)
			let inLastName = point.lastName.lowercased().contains(searched)
			let inReason = point.pointDescription.lowercased().contains(searched)
            let inName = point.type.pointName.lowercased().contains(searched)
			return (inFirstName || inLastName || inReason || inName)
		})
		tableView.reloadData()
	}
    
	func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
    
    @IBAction func sortPoints(_ sender: Any) {
        let width : Int = Int(self.view.frame.width - 20)
        let height = 265
        
        let contentView = SortHistoryView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        contentView.delegate = self
        contentView.updateSegmentedControl()
        p = PopupView(contentView: contentView)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        
        let xPos :CGFloat = self.view.frame.width / 2
        let yPos = self.view.frame.height / 2
        let location = CGPoint.init(x: xPos, y: yPos)
        //p?.showType = .slideInFromBottom
        p?.dismissType = .slideOutToBottom
        p?.show(at: location, in: (self.tabBarController?.view)!)
    }
    
    func dismissSortPopup() {
        p?.dismiss(animated: true)
    }
    
}

class SortHistoryView : UIView {
    
    @IBOutlet weak var sortByDateSubmittedControl: UISegmentedControl!
    @IBOutlet weak var ascDescControl: UISegmentedControl!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    var delegate : HousePointsHistoryViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("SortHistoryView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        
        backgroundView.layer.cornerRadius = DefinedValues.radius
        
        sortButton.layer.cornerRadius = DefinedValues.radius
       
        let closeImage = #imageLiteral(resourceName: "SF_xmark").withRenderingMode(.alwaysTemplate)
        closeButton.setBackgroundImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.lightGray
        closeButton.setTitle("", for: .normal)

    }
    
    // To be done after delegate has been assigned and before the view has been presented
    func updateSegmentedControl() {
        sortByDateSubmittedControl.selectedSegmentIndex = ((delegate?.sortDateSubmitted ?? true) ? 0 : 1)
        ascDescControl.selectedSegmentIndex = ((delegate?.sortDescending ?? true) ? 0 : 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func sortAndDismiss(_ sender: Any) {
        delegate?.sortDateSubmitted = true
        delegate?.sortDescending = true
        if (sortByDateSubmittedControl.selectedSegmentIndex == 1) {
            delegate?.sortDateSubmitted = false
        }
        if (ascDescControl.selectedSegmentIndex == 1) {
            delegate?.sortDescending = false
        }
        delegate?.resfreshData()
        delegate?.dismissSortPopup()
    }
    
    @IBAction func closeView(_ sender: Any) {
        delegate?.dismissSortPopup()
    }
    
}
