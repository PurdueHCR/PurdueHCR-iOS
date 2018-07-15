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
    private init(){}
    private var firstRun = true;
    private let fbh = FirebaseHelper();
    
    private var _pointSystem: [PointGroup]? = nil;
    
    func getPointGroups() -> [PointGroup]?{
        if(self._pointSystem == nil){
            fbh.retrievePointTypes(onDone: { [weak self] (pg:[PointGroup]) in
                if let strongSelf = self {
                    strongSelf._pointSystem = pg
                }
            })
        }
        return self._pointSystem
    }
    
    func createUser(onDone:@escaping (_ err:Error?)->Void ){
        fbh.createUser(onDone: onDone)
    }
    func getUserWhenLogginIn(id:String, onDone:@escaping (_ success:Bool) ->Void ){
        fbh.getUserWhenLogIn(id: id, onDone: onDone)
    }
    
    func getPointGroups(onDone:@escaping ([PointGroup])-> Void) -> [PointGroup]? {
        if(self._pointSystem == nil){
            fbh.retrievePointTypes(onDone: {(pg:[PointGroup]) in
                onDone(pg)
            })
            return self._pointSystem
        }
        else{
            onDone(self._pointSystem!)
            return self._pointSystem
        }
        
    }
    
    
    func writePoints(log:PointLog, onDone:@escaping (_ err:Error?)->Void){
        // take in a point log, write it to house then write the ref to the user
        fbh.addPointLog(log: log, onDone: onDone)
    }
    
    
    
    func isLoaded() -> Bool{
        if(firstRun){
            firstRun = false;
            _ = getPointGroups()
        }
        //print(_pointSystem != nil)
        return _pointSystem != nil;
    }
    
    func syncronize() {
        while(!isLoaded()){}
    }

}


//class DataManager {
//
//    func retrievePointTypes() -> [PointGroup] {
//        return nil;
//    }
//}
