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

class PointOptionViewController: UITableViewController{

    var refresher: UIRefreshControl?
    
    var pointSystem = [PointGroup]()
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        // Do any additional setup after loading the view, typically from a nib.
        pointSystem = DataManager.sharedManager.getPointGroups() ?? [PointGroup]()
        if(pointSystem.count == 0){
            resfreshData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Point Options"
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (pointSystem[section].points.count);
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PointTypeCell
        cell.typeLabel.text = pointSystem[indexPath.section].points[indexPath.row].pointDescription
        
        return(cell)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (pointSystem.count)
    }

    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pointSystem[section].pointValue.description + " Points" ;
    }
    
    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "cell_push", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let nextViewController = segue.destination as! TypeSubmitViewController
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        nextViewController.type = pointSystem[(indexPath?.section)!].points[(indexPath?.row)!]
    }
    
    @objc func resfreshData(){
        DataManager.sharedManager.refreshPointGroups(onDone: {(pg:[PointGroup]) in
            self.pointSystem = pg
            DispatchQueue.main.async { [weak self] in
                if(self != nil){
                    self?.tableView.reloadData()
                }
            }
            self.tableView.refreshControl?.endRefreshing()
        })
    }
}




