//
//  RECPointOptionTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 10/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class RECPointOptionTableViewController: PointOptionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshData()
    }


    override func checkPermission(pointType:PointType) -> Bool{
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "SelectPointType", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "SelectPointType"){
            // get a reference to the second view controller
            let nextViewController = segue.destination as! RECPointCreationTableViewController
            
            let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
            //        if(isFiltering()){
            //            nextViewController.type = filteredPoints[(indexPath?.row)!]
            //        }
            //        else{
            //            nextViewController.type = pointSystem[(indexPath?.section)!].points[(indexPath?.row)!]
            //        }
            nextViewController.type = pointSystem[indexPath!.section].points[indexPath!.row]
        }
    }
    

}
