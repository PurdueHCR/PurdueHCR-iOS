//
//  HouseTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 10/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import AZDropdownMenu

class LogCountCell :UITableViewCell{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var countLable: UILabel!
    
}

class HouseTableViewController: UITableViewController {
    
    var houseName:String?
    var logCount = [LogCount]()
    var refresher: UIRefreshControl?
    
    var activityIndicator = UIActivityIndicatorView()
    
    //I am really sorry to whoever works on this after me.
    //I was in a rush and could not think of a way to do this dynamically
    var floorIds = [String]()
    let codes = ["Copper":["2S","2N"],"Palladium":["3S","3N"],"Platinum":["4S","4N"],"Silver":["5S","5N"],"Titanium":["6S","6N","Shreve"]]
    var dropDownOptions = [String]()
    var menu:AZDropdownMenu?
//    let COPPER_CODES = ["2S","2N"]
//    let PALLADIUM_CODES = ["3S","3N"]
//    let PLATINUM_CODES = ["4S","4N"]
//    let SILVER_CODES = ["5S","5N"]
//    let TITANIUM_CODES = ["6S","6N","Shreve"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = houseName!
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        
        
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refresher
        resfreshData()
        self.tableView.allowsSelection = false
        floorIds = codes[houseName!] ?? [String]()
        dropDownOptions = floorIds
        dropDownOptions.append("Total")
        menu = AZDropdownMenu(titles: dropDownOptions)
        menu!.cellTapHandler = {(indexPath: IndexPath) -> Void in
            if(self.dropDownOptions[indexPath.row] == "Total"){
                self.floorIds = self.codes[self.houseName!] ?? [String]()
            }
            else{
                self.floorIds = [self.dropDownOptions[indexPath.row]]
            }
            self.resfreshData()
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return logCount.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCountCell", for: indexPath) as! LogCountCell
        
        cell.nameLabel.text = logCount[indexPath.row].name
        cell.countLable.text = logCount[indexPath.row].count.description
        return cell
    }
    

    @objc func refresh(){
        self.tableView.refreshControl?.beginRefreshing()
        resfreshData()
    }


    
    func resfreshData(){
        activityIndicator.startAnimating()
        DataManager.sharedManager.getAllPointLogsForHouse(house: self.houseName!) { (logs) in
            guard let pointTypes = DataManager.sharedManager.getPoints() else{
                self.notify(title: "Failure", subtitle: "Could not load points.", style: .danger)
                self.activityIndicator.stopAnimating()
                return
            }
            var countOfLogs = [LogCount]()
            for type in pointTypes{
                countOfLogs.append(LogCount(nm: type.pointName, id: type.pointID))
            }
            countOfLogs.sort(by: { (a, b) -> Bool in
                return a.typeId < b.typeId
            })
            for log in logs{
                if(self.floorIds.contains(log.floorID)){
                    countOfLogs[abs(log.type.pointID)-1].incrementCount()
                }
            }
            
            self.logCount = countOfLogs
            DispatchQueue.main.async { [weak self] in
                if(self != nil){
                    self?.tableView.reloadData()
                }
            }
            self.activityIndicator.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func showDropdown(_ sender: Any) {
        if (self.menu?.isDescendant(of: self.view) == true) {
            self.menu?.hideMenu()
        } else {
            self.menu?.showMenuFromView(self.view)
        }
    }
    
    

}


class LogCount {
    var name:String
    var typeId:Int
    var count = 0
    
    init(nm:String, id:Int){
        name=nm
        typeId=id
    }
    
    func incrementCount(){
        count += 1
    }
    
}
