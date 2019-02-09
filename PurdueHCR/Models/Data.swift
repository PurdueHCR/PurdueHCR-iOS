
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//
//  This file contains all of the models for the app. 
//

import Foundation
import UIKit
import Firebase

class PointType {
    var pointValue:Int
    var pointDescription:String
    var residentCanSubmit:Bool
    var pointID:Int
    var permissionLevel:Int
    var isEnabled:Bool
    
    init(pv:Int,pd:String,rcs:Bool,pid:Int, permissionLevel:Int, isEnabled:Bool){
        self.pointValue = pv
        self.pointDescription = pd
        self.residentCanSubmit = rcs
        self.pointID = pid
        self.permissionLevel = permissionLevel
        self.isEnabled = isEnabled
    }

}

class House {
    var houseID: String
    var totalPoints: Int
    var hexColor: String
    var numberOfResidents: Int
    var topScoreUsers : [UserModel]?
    init(id:String, points:Int,hexColor:String, numberOfResidents:Int ){
        self.houseID = id
        self.totalPoints = points
        self.hexColor = hexColor
        self.numberOfResidents = numberOfResidents
    }
    
    
}
extension House:Equatable {
    static func == (lhs: House, rhs: House) -> Bool {
        return
            lhs.houseID == rhs.houseID
    }
}



class PointGroup{
    var points = [PointType]();
    var pointValue: Int;

    init(val:Int){
        self.pointValue = val
    }
    func add(pt:PointType){
        points.append(pt)
    }
}

class PointLog {
    
    public let REJECTED_STRING:String = "DENIED: "
    public let SHREVE_RESIDENT:String = "(Shreve) "

    //Values stored in Firebase
    var approvedBy:String?
    var approvedOn:Timestamp?
    var pointDescription:String;
    var floorID:String;
    var type:PointType;
    var resident:String;
    var residentRef:DocumentReference
    var residentReportTime:Timestamp?
    var logID:String? = nil;
    
    //Values stayed local
    var wasHandled:Bool;
    
    
    /// Initialization for newly created points. If the points are being pulled from Firebase database, use the other init method.
    ///
    /// - Parameters:
    ///   - pointDescription: Description of PointLog
    ///   - resident: Name of resident who submitted
    ///   - type: PointType for which the point is being submitted for
    ///   - floorID: Id of the floor for who submitted it
    ///   - residentRef: Firebase reference to the resident who submitted it
    init(pointDescription:String, resident:String, type:PointType, floorID:String, residentRef:DocumentReference){
        self.pointDescription = pointDescription
        self.floorID = floorID
        self.type = type
        self.resident = resident
        self.residentRef = residentRef
        self.residentReportTime = Timestamp.init()
        self.wasHandled = false
    }
    
    /// Initialization method for points pulled from Firebase Database
    ///
    /// - Parameters:
    ///   - id: FirebaseId of the log
    ///   - document: Dictionary that was returned from the database
    init(id:String,document:[String:Any]){
        
        self.logID = id
        
        self.floorID = document["FloorID"] as! String
        self.pointDescription = document["Description"] as! String
        self.resident = document["Resident"] as! String
        self.residentRef = document["ResidentRef"] as! DocumentReference
        self.approvedBy = document["ApprovedBy"] as! String?
        self.approvedOn = document["ApprovedOn"] as! Timestamp?
        self.residentReportTime = document["ResidentReportTime"] as! Timestamp?
        
        
        let idValue = (document["PointTypeID"] as! Int)
        if(idValue < 1){
            self.wasHandled = false
        }
        else{
            self.wasHandled = true
        }
        self.type = DataManager.sharedManager.getPointType(value: abs(idValue))
        if(floorID == "Shreve"){
            resident = SHREVE_RESIDENT+resident
        }
    }
    
    func wasRejected() -> Bool {
        return self.pointDescription.contains(REJECTED_STRING)
    }
    
    /// changes the value of the point log when it is being rejected or approved.
    /// NOTE: It does not matter if the point was already handled. It will work properly either way
    ///
    /// - Parameters:
    ///   - approved: Bool Point is approved
    ///   - preapproved: Bool Point was preapproved
    func updateApprovalStatus( approved:Bool,preapproved:Bool = false){
        wasHandled = true
        if(approved){
            //Approve the point
            if(wasRejected()){
                //Point was previously rejected so remove Rejected String
                self.pointDescription = String(self.pointDescription.dropFirst(REJECTED_STRING.count))
            }
            
            if(preapproved){
                self.approvedBy = "Preapproved"
            }
            else{
                self.approvedBy = User.get(.name) as! String?
            }
            
            self.approvedOn = Timestamp.init()
        }
        else{
            //Reject the point
            if(!wasRejected()){
                //Point was not already rejected
                self.pointDescription = REJECTED_STRING + self.pointDescription
                self.approvedBy = User.get(.name) as! String?
                self.approvedOn = Timestamp.init()
            }
            //else point was already rejected so it does not need ot be updated
        }
    }
    
    func convertToDict()->[String:Any]{
        var pointTypeIDValue = self.type.pointID
        if(!wasHandled){
            pointTypeIDValue = pointTypeIDValue * -1
        }
        var residentName = self.resident
        if(floorID == "Shreve"){
            residentName = String(residentName.dropFirst(SHREVE_RESIDENT.count))
            
        }

        var dict: [String : Any] = [
            "Description":self.pointDescription,
            "FloorID":self.floorID,
            "PointTypeID":pointTypeIDValue,
            "Resident":residentName,
            "ResidentRef":self.residentRef,
            "ResidentReportTime":self.residentReportTime!
        ]
        if(self.approvedBy != nil){
            dict["ApprovedBy"] = self.approvedBy!
        }
        if(self.approvedOn != nil){
            dict["ApprovedOn"] = self.approvedOn!
        }
        return dict
    }
    
}

extension PointLog: Equatable {
    static func == (lhs: PointLog, rhs: PointLog) -> Bool {
        return
            lhs.type.pointID == rhs.type.pointID &&
                lhs.resident == rhs.resident &&
                lhs.pointDescription == rhs.pointDescription &&
                lhs.logID == rhs.logID
    }
}

class Reward {
    var requiredValue: Int
    var rewardName: String
    var fileName: String
    var image: UIImage?
    
    init(requiredValue:Int, fileName:String, rewardName:String){
        self.requiredValue = requiredValue
        self.fileName = fileName
        self.rewardName = rewardName
    }
    
}

class HouseCode {
    var code:String
    var house:String
    var floorID:String
    init(code:String,house:String, floorID:String){
        self.code = code
        self.house = house
        self.floorID = floorID
    }
}

class Link {
    var id:String
    var description:String
    var singleUse:Bool
    var pointTypeID:Int
    var enabled:Bool
    var archived:Bool
    //Constructor for code from Database
    init(id:String, description:String,singleUse:Bool, pointTypeID:Int, enabled:Bool, archived:Bool){
        self.id = id
        self.description = description
        self.singleUse = singleUse
        self.pointTypeID = pointTypeID
        self.enabled = enabled
        self.archived = archived
    }
    //Constructor for when the qr code is created
    init(description:String, singleUse:Bool, pointTypeID:Int){
        self.id = ""
        self.description = description
        self.singleUse = singleUse
        self.pointTypeID = pointTypeID
        self.enabled = false
        self.archived = false
    }
}

class LinkList {
    var unarchivedLinks = [Link]()
    var archivedLinks = [Link]()
    var allLinks = [Link]()
    init( _ links:[Link]){
        allLinks = links
        reloadLinks()
    }
    convenience init(){
        self.init([Link]())
    }
    func getCombinedLinks() ->[Link]{
        return allLinks
    }
    func reloadLinks(){
        archivedLinks.removeAll()
        unarchivedLinks.removeAll()
        for link in allLinks {
            if(link.archived){
                archivedLinks.append(link)
            }
            else{
                unarchivedLinks.append(link)
            }
        }
    }
}

class UserModel {
    var userName:String
    var totalPoints:Int
    
    init(name:String, points:Int) {
        self.userName = name
        self.totalPoints = points
    }
}

class SystemPreferences {
	var isHouseEnabled : Bool
	var houseEnabledMessage : String
	
	init(isHouseEnabled: Bool, houseEnabledMessage: String) {
		self.isHouseEnabled = isHouseEnabled
		self.houseEnabledMessage = houseEnabledMessage
	}
}

