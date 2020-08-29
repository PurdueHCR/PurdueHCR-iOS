
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//
//  This file contains all of the models for the app. 
//

import Foundation
import UIKit
import Firebase

class DefinedValues {
	
	// Colors
	
	static let systemBlue = UIColor.init(red: 0.00/255.0, green: 122.0/255.0, blue: 1.00, alpha: 1.0)
	static let systemYellow = UIColor.init(red: 1.00, green: 204.0/255.0, blue: 0.0, alpha: 1.0)
	static let systemRed = UIColor.init(red: 1.00, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
	static let systemGreen = UIColor.init(red: 52.0/255.0, green: 199.0/255.0, blue: 89.0/255.0, alpha: 1.0)
    static let systemGray4 = UIColor.init(red: 209/255.0, green: 209/255.0, blue: 214/255.0, alpha: 1.0)
	static let systemGray5 = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1.0)
	
	// Raw Values
	
	static let radius : CGFloat = 10.0
	
}

class PointType {
	
	enum PermissionLevel: Int {
		case resident = 0
		case rhp = 1
		case rec = 2
		case faculty = 3
        case priv = 4
        case ea = 5
	}
	
    var pointValue:Int
	var pointName:String
    var pointDescription:String
    var residentCanSubmit:Bool
    var pointID:Int
    var permissionLevel:PermissionLevel
    var isEnabled:Bool
    
	init(pv:Int,pn:String,pd:String,rcs:Bool,pid:Int, permissionLevel:PermissionLevel, isEnabled:Bool){
        self.pointValue = pv
		self.pointName = pn
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
    var topScoreUsers : [UserModel]?
	var numResidents : Int
	init(id:String, points:Int, hexColor:String, numResidents:Int=0){
        self.houseID = id
        self.totalPoints = points
        self.hexColor = hexColor
		self.numResidents = numResidents
    }
    
    func getPPR() -> Double {
        return Double(totalPoints) / Double(numResidents)
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
    var pointDescription:String
    var floorID:String
    var type:PointType
	var firstName:String
	var lastName:String
	var residentId:String
    var dateSubmitted:Timestamp?
	var dateOccurred:Timestamp?
    var logID:String? = nil
	var rhpNotifications:Int
	var residentNotifications:Int
    
    // Values stayed local
    var wasHandled:Bool
    
    /// Initialization for newly created points. If the points are being pulled from Firebase database, use the other init method.
    ///
    /// - Parameters:
    ///   - pointDescription: Description of PointLog
    ///   - resident: Name of resident who submitted
    ///   - type: PointType for which the point is being submitted for
    ///   - floorID: Id of the floor for who submitted it
    ///   - residentRef: Firebase reference to the resident who submitted it
	init(pointDescription:String, firstName:String, lastName:String, type:PointType, floorID:String, residentId:String, dateOccurred:Timestamp = Timestamp.init()){
        self.pointDescription = pointDescription
        self.floorID = floorID
        self.type = type
        self.firstName = firstName
		self.lastName = lastName
		self.residentId = residentId
        self.dateOccurred = dateOccurred
		self.dateSubmitted = Timestamp.init()
        self.wasHandled = false
		self.rhpNotifications = 0
		self.residentNotifications = 0
    }
	
    /// Initialization method for points pulled from Firebase Database
    ///
    /// - Parameters:
    ///   - id: FirebaseId of the log
    ///   - document: Dictionary that was returned from the database
    init(id:String, document:[String:Any]){
        
        self.logID = id
        
        self.floorID = document["FloorID"] as! String
        self.pointDescription = document["Description"] as! String
		self.firstName = document["ResidentFirstName"] as! String
		self.lastName = document["ResidentLastName"] as! String
		self.residentId = document["ResidentId"] as! String
        self.approvedBy = document["ApprovedBy"] as! String?
        self.approvedOn = document["ApprovedOn"] as! Timestamp?
        self.dateOccurred = document["DateOccurred"] as! Timestamp?
		self.dateSubmitted = document["DateSubmitted"] as! Timestamp?
		self.rhpNotifications = document["RHPNotifications"] as! Int
		self.residentNotifications = document["ResidentNotifications"] as! Int
		
        let idValue = (document["PointTypeID"] as! Int)
        if(idValue < 1){
            self.wasHandled = false
        }
        else{
            self.wasHandled = true
        }
        self.type = DataManager.sharedManager.getPointType(value: abs(idValue))
        /*if(floorID == "Shreve"){
            firstName = SHREVE_RESIDENT + firstName
        }*/
		
		// TODO: Is the above Shreve part actually working???
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
    func updateApprovalStatus(approved:Bool, preapproved:Bool = false){
        self.wasHandled = true
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
				let firstName = User.get(.firstName) as! String
				let lastName = User.get(.lastName) as! String
				self.approvedBy = firstName + " " + lastName
            }
            
            self.approvedOn = Timestamp.init()
        }
        else{
            //Reject the point
            if(!wasRejected()){
                //Point was not already rejected
                self.pointDescription = REJECTED_STRING + self.pointDescription
				let firstName = User.get(.firstName) as! String
				let lastName = User.get(.lastName) as! String
				self.approvedBy = firstName + " " + lastName
                self.approvedOn = Timestamp.init()
            }
            //else point was already rejected so it does not need to be updated
        }
    }
    
    func convertToDict()->[String:Any]{
        var pointTypeIDValue = self.type.pointID
        if(!wasHandled){
            pointTypeIDValue = pointTypeIDValue * -1
        }
        var firstName = self.firstName
        if(firstName.contains(SHREVE_RESIDENT)){
            firstName = String(firstName.dropFirst(SHREVE_RESIDENT.count))
		}

        var dict: [String : Any] = [
            "Description":self.pointDescription,
            "FloorID":self.floorID,
            "PointTypeID":pointTypeIDValue,
            "ResidentFirstName":firstName,
			"ResidentLastName":self.lastName,
            "ResidentId":self.residentId,
            "DateOccurred":self.dateOccurred!,
			"DateSubmitted":self.dateSubmitted!,
			"ResidentNotifications":0,
			"RHPNotifications":0
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

extension PointLog: Equatable, CustomStringConvertible {
    var description: String {
        return convertToDict().description
    }
    
    static func == (lhs: PointLog, rhs: PointLog) -> Bool {
        return
            lhs.type.pointID == rhs.type.pointID &&
                lhs.firstName == rhs.firstName &&
				lhs.lastName == rhs.lastName &&
                lhs.pointDescription == rhs.pointDescription &&
                lhs.logID == rhs.logID
    }
}

class MessageLog {
	
	enum MessageType: String {
		case comment = "comment"
		case approve = "approve"
		case reject = "reject"
	}
	
	var creationDate: Timestamp
	var message: String
	var senderFirstName: String
	var senderLastName: String
	var senderPermissionLevel: PointType.PermissionLevel
	var messageType: MessageType
	
	init(creationDate: Timestamp, message: String, senderFirstName: String, senderLastName: String, senderPermissionLevel: PointType.PermissionLevel, messageType: MessageType) {
		self.creationDate = creationDate
		self.message = message
		self.senderFirstName = senderFirstName
		self.senderLastName = senderLastName
		self.senderPermissionLevel = senderPermissionLevel
		self.messageType = messageType
	}
	
	/// Initialization method for points pulled from Firebase Database
	///
	/// - Parameters:
	///   - id: FirebaseId of the log
	///   - document: Dictionary that was returned from the database
	init(document:[String:Any]){
		
		self.creationDate = document["CreationDate"] as! Timestamp
		self.message = document["Message"] as! String
		self.senderFirstName = document["SenderFirstName"] as! String
		self.senderLastName = document["SenderLastName"] as! String
		self.senderPermissionLevel = document["SenderPermissionLevel"] as! PointType.PermissionLevel
		self.messageType = MessageType(rawValue: document["MessageType"] as! String)!
	}
	
	func convertToDict()->[String:Any]{
		
		let dict: [String : Any] = [
			"CreationDate":self.creationDate,
			"Message":self.message,
			"SenderFirstName":senderFirstName,
			"SenderLastName":self.senderLastName,
			"SenderPermissionLevel":self.senderPermissionLevel.rawValue,
			"MessageType":self.messageType.rawValue
		]
		
		return dict
	}
	
}

class Reward {
    var requiredPPR: Int
    var rewardName: String
    var fileName: String
    var image: UIImage?
    
    init(requiredPPR:Int, fileName:String, rewardName:String){
        self.requiredPPR = requiredPPR
        self.fileName = fileName
        self.rewardName = rewardName
    }
    
}

class HouseCode {
	
	// TODO: Make house and floor ids optional bc of REC and FHP
	
    var code:String
	var codeName:String
	var permissionLevel:Int
    var house:String
    var floorID:String
	init(code:String, codeName:String = "", permissionLevel:Int = 0, house:String = "", floorID:String = ""){
        self.code = code
		self.codeName = codeName
		self.permissionLevel = permissionLevel
        self.house = house
        self.floorID = floorID
    }
	
	/// Initialization method for house codes pulled from Firebase Database
	///
	/// - Parameters:
	///   - id: FirebaseId of the log
	///   - document: Dictionary that was returned from the database
	init(id:String,document:[String:Any]){
		
		self.code = document["Code"] as! String
		self.codeName = document["CodeName"] as! String
		self.permissionLevel = document["PermissionLevel"] as! Int
		self.floorID = document["FloorID"] as! String
		self.house = document["House"] as! String
		
	}
	
	func convertToDict()->[String:Any]{
		
		let dict: [String : Any] = [
			"Code":self.code,
			"CodeName":self.codeName,
			"PermissionLevel":permissionLevel,
			"FloorID":self.floorID,
			"House":self.house,
		]
		
		return dict
	}
	
}

class Link {
    var id:String
    var description:String
    var singleUse:Bool
    var pointTypeID:Int
    var pointTypeDescription:String
    var pointTypeName:String
    var pointTypeValue:Int
    var enabled:Bool
    var archived:Bool
    var creatorID:String
    var dynamicLink:String
    var claimedCount:Int
    
    // Constructor for code from Database
    init(id:String, dynamicLink:String, description:String, singleUse:Bool, pointTypeID:Int, pointTypeName:String, pointTypeDescription:String, pointTypeValue:Int, creatorID:String, enabled:Bool, archived:Bool, claimedCount:Int) {
        self.id = id
        self.description = description
        self.singleUse = singleUse
        self.pointTypeID = pointTypeID
        self.pointTypeDescription = pointTypeDescription
        self.pointTypeName = pointTypeName
        self.pointTypeValue = pointTypeValue
        self.creatorID = creatorID
        self.dynamicLink = dynamicLink
        self.enabled = enabled
        self.archived = archived
        self.claimedCount = claimedCount
    }
    
    // Constructor for when the qr code is created
    init(description:String, singleUse:Bool, pointTypeID:Int, pointTypeName:String, pointTypeDescription: String, pointTypeValue: Int) {
        self.id = ""
        self.description = description
        self.singleUse = singleUse
        self.pointTypeID = pointTypeID
        self.pointTypeDescription = pointTypeDescription
        self.pointTypeName = pointTypeName
        self.pointTypeValue = pointTypeValue
        self.creatorID = User.get(.id) as! String
        self.dynamicLink = ""
        self.enabled = false
        self.archived = false
        self.claimedCount = 0
    }
    
    // Constructor for code from API response
    init(data:[String:Any]) {
        print("data is", data)
        self.id = data["id"] as! String
        self.archived = data["archived"] as! Bool
        self.creatorID = data["creatorId"] as! String
        self.description = data["description"] as! String
        self.enabled = data["enabled"] as! Bool
        self.pointTypeID = data["pointId"] as! Int
        self.pointTypeName = data["pointTypeName"] as! String
        self.pointTypeDescription = data["pointTypeDescription"] as! String
        self.pointTypeValue = data["pointTypeValue"] as! Int
        self.singleUse = data["singleUse"] as! Bool
        self.dynamicLink = data["dynamicLink"] as! String
        self.claimedCount = data["claimedCount"] as! Int
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
    var showRewards: Bool
	var iosVersion : String
    var suggestedPointIDs : String
    var competitionHiddenMessage : String
    var isCompetitionVisible : Bool
	
    init(isHouseEnabled: Bool, houseEnabledMessage: String, showRewards: Bool, iosVersion: String, suggestedPointIDs: String, isCompetitionVisible: Bool, competitionHiddenMessage: String) {
		self.isHouseEnabled = isHouseEnabled
		self.houseEnabledMessage = houseEnabledMessage
        self.showRewards = showRewards
		self.iosVersion = iosVersion
        self.suggestedPointIDs = suggestedPointIDs
        self.competitionHiddenMessage = competitionHiddenMessage
        self.isCompetitionVisible = isCompetitionVisible
	}
	
	func convertToDictionary() -> [String:Any] {
		let dict : [String:Any] = [
			"isHouseEnabled":isHouseEnabled,
			"houseEnabledMessage":houseEnabledMessage,
            "showRewards":showRewards,
            "iOS_Version":iosVersion,
            "suggestedPointIDs":suggestedPointIDs,
            "competitionHiddenMessage":competitionHiddenMessage,
            "isCompetitionVisible":isCompetitionVisible
		]
		return dict
	}
	
}

