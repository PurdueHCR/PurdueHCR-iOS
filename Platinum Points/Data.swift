//
//  Data.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation

class PointType : CustomStringConvertible {
    var points : [String]? = nil;
    var pointValue: String? = nil;
    var description: String {
        return "Point Value: "+pointValue! + ", Contains: "+points!.description
    }
}

//class PointType {
//    var pointValue = 0;
//    var pointDescription:String? = nil;
//    var residentCanSubmit = false;
//    var pointID:String? = nil;
//
//}
//
//class PointGroup {
//    var points:[PointType]? = nil;
//}
//
//class PointLog {
//    var pointDescription:String? = nil;
//    var type:PointType? = nil;
//    var resident:String? = nil;
//    var id:String? = nil;
//}

