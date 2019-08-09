//
//  SubmitGrantedAwardViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 11/14/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import Firebase

class SubmitGrantedAwardViewController: TypeSubmitViewController {

    var house:House?
    /// Submit Point Log as award
    ///
    /// - Parameters:
    ///   - pointType: Type to be submitted
    ///   - descriptions: Description given by the REA/REC for reason why they were granting them the points
    override func submitPointLog(pointType: PointType, logDescription: String) {
		let firstName = User.get(.firstName) as! String
		let lastName = User.get(.lastName) as! String
		let residentId = User.get(.id) as! String
		//TODO: Decide what to do about this ViewController and fix creationDate
		let log = PointLog(pointDescription: logDescription, firstName: firstName, lastName: lastName, type: pointType, floorID: "Award", residentId: residentId, dateOccurred: Timestamp.init())
        DataManager.sharedManager.awardPointsToHouseFromREC(log: log, house: house!) { (error) in
            if(error != nil){
                if(error!.localizedDescription == "The operation couldn’t be completed. (Could not submit points because point type is disabled. error 1.)"){
                    self.notify(title: "Failed to submit", subtitle: "Point Type is no longer enabled.", style: .danger)
                }
                else{
                    self.notify(title: "Failed to submit", subtitle: "Database Error.", style: .danger)
                    print("Error in posting: ",error!.localizedDescription)
                }
                
                self.submitButton.isEnabled = true;
                return
            }
            else{
                self.navigationController?.popViewController(animated: true)
                self.notify(title: "Award Granted", subtitle: "\(log.type.pointValue) points given to \(self.house!.houseID) House.", style: .success)
            }
        }
    }
}
