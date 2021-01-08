//
//  SelectFloorsTableViewController.swift
//  PurdueHCR
//
//  Created by Brennan Doyle on 11/6/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

protocol SelectFloorsDelegate {
    func updateData(selected: [Bool], floors: [String])
}

class SelectFloorsTableViewController: UITableViewController {
    
    var delegate: SelectFloorsDelegate?
    
    let floors = ["2N", "2S", "3N", "3S", "4N", "4S", "5N", "5S", "6N"]
    var floorsSelected = [false, false, false, false, false, false, false, false, false]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return floors.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedFloorsTableViewCell", for: indexPath) as! SelectedFloorsTableViewCell

        cell.floorLabel.text = floors[indexPath.row]
        cell.floorSelected = false
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! SelectedFloorsTableViewCell
        if (!floorsSelected[indexPath.row]) {
            floorsSelected[indexPath.row] = true
            selectedCell.accessoryType = .checkmark
            self.delegate?.updateData(selected: floorsSelected, floors: floors)
        } else {
            floorsSelected[indexPath.row] = false
            selectedCell.accessoryType = .none
            self.delegate?.updateData(selected: floorsSelected, floors: floors)
        }
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
