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
