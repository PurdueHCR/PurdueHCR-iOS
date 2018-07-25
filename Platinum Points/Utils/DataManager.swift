//
//  DataManager.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import UIKit





class DataManager {
    
    public static let sharedManager = DataManager()
    private var firstRun = true;
    private let fbh = FirebaseHelper();
    private var _pointSystem: [PointGroup]? = nil;
    private var _points: [PointType]? = nil
    private var _unconfirmedPointLogs: [PointLog]? = nil
    private var _houses: [House]? = nil
    private var _rewards: [Reward]? = nil
    private var _houseCodes: [HouseCode]? = nil
    
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
            if(err != nil){
                print("Failed to confirm or deny point")
            }
            else{
                if let index = self?._unconfirmedPointLogs!.index(of: log) {
                    self?._unconfirmedPointLogs!.remove(at: index)
                }
            }
            onDone(err)
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
        print("House refersh")
        fbh.refreshHouseInformation(onDone: { (houses:[House],codes:[HouseCode]) in
            self._houses = houses
            self._houseCodes = codes
            onDone(houses)
        })
    }
    
    func getHouseCodes() -> [HouseCode]?{
        return self._houseCodes
    }
    
    func getHouses() -> [House]?{
        return self._houses
    }
    
    func refreshRewards(onDone:@escaping ( _ rewards:[Reward])-> Void){
        fbh.refreshRewards(onDone: { ( rewards:[Reward]) in
            let total = rewards.count
            let counter = AppUtils.AtomicCounter(identifier: "refreshRewards")
            for reward in rewards {
                self.getImage(filename: reward.fileName, onDone: {(image:UIImage) in
                    reward.image = image
                    counter.increment()
                    if(counter.value == total){
                        self._rewards = rewards
                        onDone(rewards)
                    }
                })
            }
            
        })
    }
    
    func getRewards() -> [Reward]?{
        return self._rewards
    }
    
    func getImage(filename:String, onDone:@escaping ( _ image:UIImage) ->Void ){
        let url = getDocumentsDirectory()
        let fileManager = FileManager.default
        let imagePath = url.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: imagePath.absoluteString){
            onDone(UIImage(contentsOfFile: imagePath.absoluteString)!)
        }else{
            fbh.retrievePictureFromFilename(filename: filename, onDone: {(image:UIImage) in
                if let data = UIImagePNGRepresentation(image) {
                    try? data.write(to: imagePath)
                }
                onDone(image)
            })
        }
    }
    
    func initializeData(finished:@escaping ()->Void){
        print("INITIALIZE")
        let counter = AppUtils.AtomicCounter(identifier: "initializer")
        guard let _ = User.get(.name) else{
            print("FAILED INIT")
            return;
        }
        if let id = User.get(.id) as! String?{
            getUserWhenLogginIn(id: id, onDone: {(done:Bool) in return})
        }
        
        refreshPointGroups(onDone: {(onDone:[PointGroup]) in
            counter.increment()
            self.refreshUnconfirmedPointLogs(onDone:{(pointLogs:[PointLog]) in
                counter.increment()
                if(counter.value == 4){
                    finished();
                }
            } )
        })
        refreshHouses(onDone:{(onDone:[House]) in
            counter.increment()
            if(counter.value == 4){
                finished();
            }
        })
        refreshRewards(onDone: {(rewards:[Reward]) in
            counter.increment()
            if(counter.value == 4){
                finished();
            }
        })
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}


//class DataManager {
//
//    func retrievePointTypes() -> [PointGroup] {
//        return nil;
//    }
//}
