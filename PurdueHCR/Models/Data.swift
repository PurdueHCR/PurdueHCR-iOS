//
//  Data.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PointTypes : CustomStringConvertible {
    var points : [String]? = nil;
    var pointValue: String? = nil;
    var description: String {
        return "Point Value: "+pointValue! + ", Contains: "+points!.description
    }
}

class PointType {
    var pointValue:Int
    var pointDescription:String
    var residentCanSubmit:Bool
    var pointID:Int
    
    init(pv:Int,pd:String,rcs:Bool,pid:Int){
        self.pointValue = pv
        self.pointDescription = pd
        self.residentCanSubmit = rcs
        self.pointID = pid
    }

}

class House {
    var houseID: String
    var totalPoints: Int
    var hexColor: String
    var numberOfResidents: Int
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
    var pointDescription:String;
    var type:PointType;
    var resident:String;
    var residentRef:DocumentReference
    var floorID:String;
    var logID:String? = nil;
    init(pointDescription:String, resident:String, type:PointType, floorID:String, residentRef:DocumentReference){
        self.pointDescription = pointDescription
        self.floorID = floorID
        self.type = type
        self.resident = resident
        self.residentRef = residentRef
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


