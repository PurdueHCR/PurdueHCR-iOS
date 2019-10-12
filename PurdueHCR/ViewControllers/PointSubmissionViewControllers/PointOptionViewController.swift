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
        // Do any additional setup after loading the view, typically from a nib.
		self.pointSystem = self.sortIntoPointGroupsWithPermission(arr: DataManager.sharedManager.pointTypes)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Points"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        let radius: CGFloat = 10.0
        suggested1.layer.cornerRadius = radius
        suggested2.layer.cornerRadius = radius
        suggested3.layer.cornerRadius = radius
        suggested4.layer.cornerRadius = radius
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.title = nil//"Submit Points"
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
            if (pointSystem[indexPath.section].points[indexPath.row].pointID == 7) {
                suggested1.titleLabel?.text = pointSystem[indexPath.section].points[indexPath.row].pointName
                suggested1.titleLabel?.sizeToFit()
            } else if (pointSystem[indexPath.section].points[indexPath.row].pointID == 45) {
                suggested2.titleLabel?.text = pointSystem[indexPath.section].points[indexPath.row].pointName
            } else if (pointSystem[indexPath.section].points[indexPath.row].pointID == 9) {
                suggested3.titleLabel?.text = pointSystem[indexPath.section].points[indexPath.row].pointName
            } else if (pointSystem[indexPath.section].points[indexPath.row].pointID == 10) {
                suggested4.titleLabel?.text = pointSystem[indexPath.section].points[indexPath.row].pointName
            }
            
            cell.typeLabel.text = pointSystem[indexPath.section].points[indexPath.row].pointName
            cell.accessibilityIdentifier = pointSystem[indexPath.section].points[indexPath.row].pointName
        }
        //suggestedPointsView.setNeedsDisplay()
        return(cell)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
		if (!DataManager.sharedManager.systemPreferences!.isHouseEnabled) {
			let message = DataManager.sharedManager.systemPreferences!.houseEnabledMessage
			emptyMessage(message: message)
			navigationItem.searchController = nil
			return 0
		}
		else if isFiltering() {
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
				killEmptyMessage()
				navigationItem.searchController = searchController
				return (pointSystem.count)
			} else {
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
        return pointSystem[section].pointValue.description + " Points" ;
    }
    
    // Runs when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "cell_push", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let nextViewController = segue.destination as! TypeSubmitViewController
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        if(isFiltering()){
            nextViewController.type = filteredPoints[(indexPath?.row)!]
        }
        else{
          	nextViewController.type = pointSystem[(indexPath?.section)!].points[(indexPath?.row)!]
        }
        
    }
    
    @objc func resfreshData(){
		DataManager.sharedManager.refreshSystemPreferences { (sysPref) in
			if (sysPref != nil) {
				DataManager.sharedManager.refreshPointTypes(onDone: {(types:[PointType]) in
					self.pointSystem = self.sortIntoPointGroupsWithPermission(arr: types)
					//DispatchQueue.main.async { [weak self] in
					//	if(self != nil){
                    self.tableView.reloadData()
					//	}
					//}
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
        if(!arr.isEmpty){
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




