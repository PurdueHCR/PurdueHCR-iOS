//
//  ViewEventTableViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 6/27/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

class ViewEventTableViewController: UITableViewController {

    @IBOutlet weak var goingButton: UIButton!
    @IBOutlet weak var iCalExportButton: UIButton!
    @IBOutlet weak var gCalExportButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    var going = true // To be set later when connected to database
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iCalExportButton.layer.cornerRadius = DefinedValues.radius
        gCalExportButton.layer.cornerRadius = DefinedValues.radius
        
        self.dateLabel.text = event?.fullDate
        self.locationLabel.text = event?.location
        self.hostLabel.text = event?.house
        self.detailsLabel.text = event?.details
        
        if (going) {
            if #available(iOS 13.0, *) {
                goingButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        } else {
            if #available(iOS 13.0, *) {
                goingButton.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    @IBAction func goingAction(_ sender: Any) {
    
    
        if (going) {
            if #available(iOS 13.0, *) {
                goingButton.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            going = false
        } else {
            if #available(iOS 13.0, *) {
                goingButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            going = true
        }
        
    }
    
    
}
