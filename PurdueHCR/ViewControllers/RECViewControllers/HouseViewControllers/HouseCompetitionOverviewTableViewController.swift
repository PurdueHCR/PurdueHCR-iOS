//
//  HouseCompetitionOverviewTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 10/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class HouseCompetitionOverviewTableViewController: UITableViewController {

    
    let houses = ["Copper","Palladium","Platinum","Silver","Titanium"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "HouseSelected", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let nextViewController = segue.destination as! HouseTableViewController
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        nextViewController.houseName = self.houses[indexPath!.row]
        
    }

}
