//
//  Data.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import UIKit

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
    init(id:String, points:Int,hexColor:String ){
        self.houseID = id
        self.totalPoints = points
        self.hexColor = hexColor
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
    var floorCode:String;
    var logID:String? = nil;
    init(pointDescription:String, resident:String, type:PointType, floorCode:String){
        self.pointDescription = pointDescription
        self.floorCode = floorCode
        self.type = type
        self.resident = resident
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


