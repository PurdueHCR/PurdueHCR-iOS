//
//  HouseTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 10/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit


class LogCountCell :UITableViewCell{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var countLable: UILabel!
    
}

class HouseTableViewController: UITableViewController {
    
    var houseName:String?
    var logCount = [LogCount]()
    var refresher: UIRefreshControl?
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = houseName!
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        resfreshData()
        self.tableView.allowsSelection = false
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
    




    
    @objc func resfreshData(){
        self.tableView.refreshControl?.beginRefreshing()
        DataManager.sharedManager.getAllPointLogsForHouse(house: self.houseName!) { (logs) in
            guard let pointTypes = DataManager.sharedManager.getPoints() else{
                self.notify(title: "Failure", subtitle: "Could not load points.", style: .danger)
                return
            }
            var countOfLogs = [LogCount]()
            for type in pointTypes{
                countOfLogs.append(LogCount(nm: type.pointDescription, id: type.pointID))
            }
            countOfLogs.sort(by: { (a, b) -> Bool in
                return a.typeId < b.typeId
            })
            for log in logs{
                countOfLogs[abs(log.type.pointID)-1].incrementCount()
            }
            
            self.logCount = countOfLogs
            DispatchQueue.main.async { [weak self] in
                if(self != nil){
                    self?.tableView.reloadData()
                }
            }
            self.tableView.refreshControl?.endRefreshing()
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
