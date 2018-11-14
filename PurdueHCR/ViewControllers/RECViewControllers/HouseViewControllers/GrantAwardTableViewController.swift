//
//  GrantAwardTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 11/14/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class GrantAwardTableViewController: RECPointOptionTableViewController {
    
    var house:House?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "show_award_selected", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "show_award_selected"){
            // get a reference to the second view controller
            let nextViewController = segue.destination as! SubmitGrantedAwardViewController
            
            let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
            //        if(isFiltering()){
            //            nextViewController.type = filteredPoints[(indexPath?.row)!]
            //        }
            //        else{
            //            nextViewController.type = pointSystem[(indexPath?.section)!].points[(indexPath?.row)!]
            //        }
            nextViewController.type = pointSystem[indexPath!.section].points[indexPath!.row]
            nextViewController.house = house
        }
    }
}
