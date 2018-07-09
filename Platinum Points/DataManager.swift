//
//  DataManager.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation



private let POINTS_PLIST = Bundle.main.path(forResource: "Points", ofType: "plist")



class DataManager {
    
    public static let sharedManager = DataManager()
    private init(){}
    
    private var _pointSystem = [PointType]()
    
    func allSheet1s() -> [PointType]{
        
        if _pointSystem.count > 0 {
            return _pointSystem
        }
        
        if let allDatas = NSDictionary(contentsOfFile: POINTS_PLIST!) {
            
            for arr in allDatas {
                guard let array = arr.value as? [String] else {continue}
                guard let key = arr.key as? String else {continue}
                let type = PointType()
                type.pointValue = key
                type.points = array
                _pointSystem.append(type)
            }
            _pointSystem.sort(by: {
                let int1 = Int($0.pointValue!)
                let int2 = Int($1.pointValue!)
                return int1! < int2!
            })
        }
        return _pointSystem
    }
}


//class DataManager {
//
//    func retrievePointTypes() -> [PointGroup] {
//        return nil;
//    }
//}
