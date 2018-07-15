//
//  Data.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation

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
    init(pointDescription:String, resident:String, type:PointType){
        self.pointDescription = pointDescription
        self.type = type
        self.resident = resident
    }
}

