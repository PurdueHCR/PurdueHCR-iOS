//
//  EditSubmissionPointTypeViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/20/22.
//  Copyright © 2022 DecodeProgramming. All rights reserved.
//

import UIKit

class EditSubmissionPointTypeViewController: UITableViewController {
   
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    var lastSelection : IndexPath?
    var pointLog : PointLog?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.sharedManager.pointTypes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointTypeCell", for: indexPath)

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = DataManager.sharedManager.pointTypes[indexPath.row].pointName
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = DataManager.sharedManager.pointTypes[indexPath.row].pointName
        }

        return cell
    }
    
    @IBAction func updatePointType(_ sender: Any) {
        
        self.updateButton.isEnabled = false
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItems?.append(barButton)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            
            let newPointTypeID = DataManager.sharedManager.pointTypes[indexPath.row]
            
            if (self.pointLog!.type.pointID != newPointTypeID.pointID) {
                // User has selected a new point type id
                
                FirebaseHelper().updatePointLogPointTypeId(pointLogID: pointLog!.logID!, newPointTypeID: newPointTypeID.pointID) { err in
                    activityIndicator.stopAnimating()
                    self.updateButton.isEnabled = true
                    if (err == nil) {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                activityIndicator.stopAnimating()
                self.updateButton.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
            
            
            
            
        }
        
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.lastSelection != nil {
                self.tableView.cellForRow(at: self.lastSelection!)?.accessoryType = .none
            }

        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

            self.lastSelection = indexPath
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
