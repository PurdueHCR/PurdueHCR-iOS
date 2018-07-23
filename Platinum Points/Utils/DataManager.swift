//
//  DataManager.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation






class DataManager {
    
    public static let sharedManager = DataManager()
    private var firstRun = true;
    private let fbh = FirebaseHelper();
    private var _pointSystem: [PointGroup]? = nil;
    private var _points: [PointType]? = nil
    private var _unconfirmedPointLogs: [PointLog]? = nil
    private var _houses: [House]? = nil
    
    private init(){}
    
    func getPointGroups() -> [PointGroup]?{
        return self._pointSystem
    }
    
    func getPointType(value:Int)->PointType{
        for pt in self._points!{
            if(pt.pointID == value){
                return pt
            }
        }
        return PointType(pv: 0, pd: "Unkown Point Type", rcs: false, pid: -1) // The famous this should never happen comment
    }
    
    func createUser(onDone:@escaping (_ err:Error?)->Void ){
        fbh.createUser(onDone: onDone)
    }
    
    func getUserWhenLogginIn(id:String, onDone:@escaping (_ success:Bool) ->Void ){
        fbh.getUserWhenLogIn(id: id, onDone: onDone)
    }
    
    func refreshPointGroups(onDone:@escaping ([PointGroup])-> Void) {
        fbh.retrievePointTypes(onDone: {[weak self] (pg:[PointGroup]) in
            if let strongSelf = self {
                strongSelf._pointSystem = pg
                strongSelf._points = [PointType]()
                for group in pg {
                    strongSelf._points?.append(contentsOf: group.points)
                }
            }
            onDone(pg)
        })
    }
    
    func confirmOrDenyPoints(log:PointLog, approved:Bool, onDone:@escaping (_ err:Error?)->Void){
        fbh.approvePoint(log: log, approved: approved, onDone:{[weak self] (_ err :Error?) in
            if(err == nil){
                print("Failed to confirm or deny point")
            }
            else{
                if let index = self?._unconfirmedPointLogs!.index(of: log) {
                    self?._unconfirmedPointLogs!.remove(at: index)
                }
            }
        })
    }
    
    func writePoints(log:PointLog, onDone:@escaping (_ err:Error?)->Void){
        // take in a point log, write it to house then write the ref to the user
        fbh.addPointLog(log: log, onDone: onDone)
    }
    
    func getUnconfirmedPointLogs()->[PointLog]?{
        return self._unconfirmedPointLogs
    }
    
    func refreshUser(onDone:@escaping (_ err:Error?)->Void){
        fbh.refreshUserInformation(onDone: onDone)
    }
    
    func refreshUnconfirmedPointLogs(onDone:@escaping (_ pointLogs:[PointLog])->Void ){
        fbh.getUnconfirmedPoints(onDone: {[weak self] (pointLogs:[PointLog]) in
            if let strongSelf = self {
                strongSelf._unconfirmedPointLogs = pointLogs
            }
            onDone(pointLogs)
        })
    }
    
    func refreshHouses(onDone:@escaping ( _ houses:[House]) ->Void){
        fbh.refreshHouseInformation(onDone: { (houses:[House]) in
            self._houses = houses
            onDone(houses)
        })
    }
    
    func getHouses() -> [House]?{
        return self._houses
    }
    
    
    
    func initializeData(){
        guard let _ = User.get(.name) else{
            return;
        }
        refreshPointGroups(onDone: {(onDone:[PointGroup]) in
            
            self.refreshUnconfirmedPointLogs(onDone:{(pointLogs:[PointLog]) in} )
        })
        refreshHouses(onDone:{(onDone:[House]) in return})
    }

}


//class DataManager {
//
//    func retrievePointTypes() -> [PointGroup] {
//        return nil;
//    }
//}
