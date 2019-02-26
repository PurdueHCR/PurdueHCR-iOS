//
//  SubmitGrantedAwardViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 11/14/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class SubmitGrantedAwardViewController: TypeSubmitViewController {

    var house:House?
    /// Submit Point Log as award
    ///
    /// - Parameters:
    ///   - pointType: Type to be submitted
    ///   - descriptions: Description given by the REA/REC for reason why they were granting them the points
    override func submitPointLog(pointType: PointType, logDescription: String) {
        let name = User.get(.name) as! String
        let recRef = DataManager.sharedManager.getUserRefFromUserID(id: User.get(.id) as! String)
        let log = PointLog(pointDescription: logDescription, resident:name , type: pointType, floorID: "Award", residentRef: recRef)
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
