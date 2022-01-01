//
//  FirstViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/23/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class PointTypeCell: UITableViewCell {
    @IBOutlet var typeLabel: UILabel!
    
}

class PointOptionViewController: UITableViewController, UISearchResultsUpdating{

    @IBOutlet weak var suggestedPointsView: UIView!
    @IBOutlet weak var suggested1: UIButton!
    @IBOutlet weak var suggested2: UIButton!
    @IBOutlet weak var suggested3: UIButton!
    @IBOutlet weak var suggested4: UIButton!
    @IBOutlet weak var suggestedValue1: UILabel!
    @IBOutlet weak var suggestedValue2: UILabel!
    @IBOutlet weak var suggestedValue3: UILabel!
    @IBOutlet weak var suggestedValue4: UILabel!
    
    // The table row that corresponds to each suggested point
    var suggested1Index: IndexPath?
    var suggested2Index: IndexPath?
    var suggested3Index: IndexPath?
    var suggested4Index: IndexPath?
    
    // The suggested pointID from the system preferences
    var point1: PointType?
    var point2: PointType?
    var point3: PointType?
    var point4: PointType?
    
    var tappedPoint: PointType?
    
    var refresher: UIRefreshControl?
    let searchController = UISearchController(searchResultsController: nil)
    
    var pointSystem = [PointGroup]()
    var filteredPoints = [PointType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        
		self.pointSystem = self.sortIntoPointGroupsWithPermission(arr: DataManager.sharedManager.pointTypes)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Points"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Check if REC account which does not have suggested points view.
        if (suggestedPointsView != nil) {
            let pointRadius: CGFloat = suggestedValue1.frame.height / 2
            let radius: CGFloat = pointRadius + 3
            
            suggested1.layer.cornerRadius = radius
            suggested2.layer.cornerRadius = radius
            suggested3.layer.cornerRadius = radius
            suggested4.layer.cornerRadius = radius
            
            suggested1.titleLabel?.numberOfLines = 2
            suggested2.titleLabel?.numberOfLines = 2
            suggested3.titleLabel?.numberOfLines = 2
            suggested4.titleLabel?.numberOfLines = 2
            
            suggestedValue1.layer.cornerRadius = pointRadius
            suggestedValue2.layer.cornerRadius = pointRadius
            suggestedValue3.layer.cornerRadius = pointRadius
            suggestedValue4.layer.cornerRadius = pointRadius
            
            var houses = DataManager.sharedManager.getHouses()!
            let house = houses.remove(at: houses.firstIndex(of: House(id: User.get(.house) as! String, points: 0, hexColor:""))!)
            suggestedValue1.layer.backgroundColor = AppUtils.hexStringToUIColor(hex: house.hexColor).cgColor
            suggestedValue2.layer.backgroundColor = AppUtils.hexStringToUIColor(hex: house.hexColor).cgColor
            suggestedValue3.layer.backgroundColor = AppUtils.hexStringToUIColor(hex: house.hexColor).cgColor
            suggestedValue4.layer.backgroundColor = AppUtils.hexStringToUIColor(hex: house.hexColor).cgColor
            
            suggested1.addTarget(self, action: #selector(openSuggestedPoint), for: .touchUpInside)
            suggested2.addTarget(self, action: #selector(openSuggestedPoint), for: .touchUpInside)
            suggested3.addTarget(self, action: #selector(openSuggestedPoint), for: .touchUpInside)
            suggested4.addTarget(self, action: #selector(openSuggestedPoint), for: .touchUpInside)
            
        }
        
        let indexString = DataManager.sharedManager.systemPreferences?.suggestedPointIDs.split(separator: ",")
        let id0 = Int(indexString![0].description)
        let id1 = Int(indexString![1].description)
        let id2 = Int(indexString![2].description)
        let id3 = Int(indexString![3].description)
        
        if (suggestedPointsView != nil) {
            // TODO: Add some method to collapse the view if there
            // are no trending points or only two trending points
            
            point1 = DataManager.sharedManager.getPointType(value: id0!)
            if (point1?.pointID != -1) {
                suggested1.setTitle(point1?.pointName, for: .normal)
                suggested1.titleLabel?.sizeToFit()
                suggestedValue1.text = String((point1?.pointValue)!)
            } else {
                suggested1.isHidden = true
                suggestedValue1.isHidden = true
            }
            
            point2 = DataManager.sharedManager.getPointType(value: id1!)
            if (point2?.pointID != -1) {
                suggested2.setTitle(point2?.pointName, for: .normal)
                suggested2.titleLabel?.sizeToFit()
                suggestedValue2.text = String((point2?.pointValue)!)
            } else {
                suggested2.isHidden = true
                suggestedValue2.isHidden = true
            }
            
            point3 = DataManager.sharedManager.getPointType(value: id2!)
            if (point3?.pointID != -1) {
                suggested3.setTitle(point3?.pointName, for: .normal)
                suggestedValue3.text = String((point3?.pointValue)!)
            } else {
                suggested3.isHidden = true
                suggestedValue3.isHidden = true
            }
            
            point4 = DataManager.sharedManager.getPointType(value: id3!)
            if (point4?.pointID != -1) {
                suggested4.setTitle(point4?.pointName, for: .normal)
                suggested4.titleLabel?.sizeToFit()
                suggestedValue4.text = String((point4?.pointValue)!)
            } else {
                suggested4.isHidden = true
                suggestedValue4.isHidden = true
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        resfreshData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPoints.count
        }
        return (pointSystem[section].points.count);
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PointTypeCell
        if(isFiltering()){
            cell.typeLabel.text = filteredPoints[indexPath.row].pointName
            cell.accessibilityIdentifier = filteredPoints[indexPath.row].pointName
        }
        else {
            cell.typeLabel.text = pointSystem[indexPath.section].points[indexPath.row].pointName
            cell.accessibilityIdentifier = pointSystem[indexPath.section].points[indexPath.row].pointName
        }
        return(cell)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let permission = User.get(.permissionLevel) as! Int
        if (!DataManager.sharedManager.systemPreferences!.isHouseEnabled && permission != 2) {
            if (suggestedPointsView != nil) {
                suggestedPointsView.frame.size.height = 0
                suggestedPointsView.isHidden = true
            }
			let message = DataManager.sharedManager.systemPreferences!.houseEnabledMessage
			emptyMessage(message: message)
			navigationItem.searchController = nil
			return 0
		}
		else if isFiltering() {
            if (suggestedPointsView != nil) {
                suggestedPointsView.frame.size.height = 0
                suggestedPointsView.isHidden = true
            }
            if(filteredPoints.count > 0){
                killEmptyMessage()
                return 1
            }
            else {
                emptyMessage(message: "Could not find points matching that description.")
                return 0
            }
		} else {
			if pointSystem.count > 0 {
                if (suggestedPointsView != nil) {
                    suggestedPointsView.frame.size.height = 230
                    suggestedPointsView.isHidden = false
                }
				killEmptyMessage()
				navigationItem.searchController = searchController
				return (pointSystem.count)
			} else {
                if (suggestedPointsView != nil) {
                    suggestedPointsView.frame.size.height = 0
                    suggestedPointsView.isHidden = true
                }
				emptyMessage(message: "There are no point types enabled for submitting.")
				navigationItem.searchController = nil
				return 0
			}
		}
		
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(isFiltering()){
            return nil
        }
        let pointValue = pointSystem[section].pointValue
        if (pointValue == 1) {
            return pointValue.description + " Point"
        }
        return pointValue.description + " Points"
    }
    
    // Runs when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "cell_push", sender: self)
    }
    
    //Runs when one of the four suggested points buttons are selected
    @objc func openSuggestedPoint(sender: UIButton!) {
        // Check if the point has an unknown point type meaning the point
        // type couldn't be found.
        if (sender.tag == 1) {
            if (point1?.pointID == -1) {
                return
            } else {
                tappedPoint = point1
            }
        } else if (sender.tag == 2) {
            if (point2?.pointID == -1) {
                return
            } else {
                tappedPoint = point2
            }
        } else if (sender.tag == 3) {
            if (point3?.pointID == -1) {
                return
            } else {
                tappedPoint = point3
            }
        } else if (sender.tag == 4) {
            if (point4?.pointID == -1) {
                return
            } else {
                tappedPoint = point4
            }
        }
        
        self.performSegue(withIdentifier: "cell_push", sender: self)
    }
    
    // This function is called before the segue from selected ROW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let nextViewController = segue.destination as! TypeSubmitViewController
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        if (indexPath != nil) {
            if(isFiltering()){
                nextViewController.type = filteredPoints[(indexPath?.row)!]
            }
            else{
                nextViewController.type = pointSystem[(indexPath?.section)!].points[(indexPath?.row)!]
            }
        } else {
            nextViewController.type = tappedPoint
        }
    }
    
    
    
    @objc func resfreshData(){
		DataManager.sharedManager.refreshSystemPreferences { (sysPref) in
			if (sysPref != nil) {
				DataManager.sharedManager.refreshPointTypes(onDone: {(types:[PointType]) in
					self.pointSystem = self.sortIntoPointGroupsWithPermission(arr: types)
					DispatchQueue.main.async { [weak self] in
						if (self != nil){
                            self!.tableView.reloadData()
						}
                    }
					self.tableView.refreshControl?.endRefreshing()
				})
			} else {
				self.notify(title: "Failure", subtitle: "Refresh Error", style: .danger)
			}
		}
    }
    
//    func filter(pg:[PointGroup]) -> [PointGroup]{
//        var pointGroups = [PointGroup]()
//        for group in pg{
//            var pointGroup = PointGroup(val: group.pointValue)
//
//        }
//    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if (isFiltering()) {
            suggestedPointsView.frame.size.height = 0
            suggestedPointsView.isHidden = true
        }
        else {
            suggestedPointsView.frame.size.height = 230
            suggestedPointsView.isHidden = false
        }
        filterContentForSearchText(searchController.searchBar.text!)
    }
	
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPoints = DataManager.sharedManager.getPoints()!.filter({( point : PointType) -> Bool in
            return point.pointName.lowercased().contains(searchText.lowercased()) && checkPermission(pointType: point)
        })
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func sortIntoPointGroupsWithPermission(arr:[PointType]) -> [PointGroup]{
        var pointGroups = [PointGroup]()
        if (!arr.isEmpty){
            var currentValue = 0
            var pg = PointGroup(val: 0)
            for i in 0..<arr.count {
                let pointType = arr[i]
                if(checkPermission(pointType: pointType)){
                    let value = pointType.pointValue
                    if(value != currentValue){
                        if(pg.pointValue != 0){
                            pointGroups.append(pg)
                        }
                        currentValue = value
                        pg = PointGroup(val:value)
                    }
                    pg.add(pt: pointType)
                }
            }
            if(pg.pointValue != 0){
                pointGroups.append(pg)
            }
        }
        return pointGroups
    }
    
    func checkPermission(pointType:PointType)->Bool {
        return pointType.residentCanSubmit && pointType.isEnabled
    }
}




