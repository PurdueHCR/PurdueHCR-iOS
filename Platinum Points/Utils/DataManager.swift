//
//  DataManager.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import NotificationBannerSwift




class DataManager {
    
    public static let sharedManager = DataManager()
    private var firstRun = true;
    private let fbh = FirebaseHelper();
    private var _pointGroups: [PointGroup]? = nil;
    private var _pointTypes: [PointType]? = nil
    private var _unconfirmedPointLogs: [PointLog]? = nil
    private var _houses: [House]? = nil
    private var _rewards: [Reward]? = nil
    private var _houseCodes: [HouseCode]? = nil
    private var _links: [Link]? = nil
    
    private init(){}
    
    func getPointGroups() -> [PointGroup]?{
        return self._pointGroups
    }
    
    func getPoints() ->[PointType]? {
        return self._pointTypes
    }
    
    func getPointType(value:Int)->PointType{
        for pt in self._pointTypes!{
            if(pt.pointID == value){
                return pt
            }
        }
        return PointType(pv: 0, pd: "Unkown Point Type", rcs: false, pid: -1) // The famous this should never happen comment
    }
    
    private func sortIntoPointGroupsWithPermission(arr:[PointType]) -> [PointGroup]{
        var pointGroups = [PointGroup]()
        if(!arr.isEmpty){
            var currentValue = 0
            var pg = PointGroup(val: 0)
            for i in 0..<arr.count {
                let pointType = arr[i]
                if(pointType.residentCanSubmit){
                    let value = pointType.pointValue
                    if(value != currentValue){
                        if(pg.pointValue != 0){
                            pointGroups.append(pg)
                        }
                        currentValue = value
                        pg = PointGroup(val:value)
                    }
                    pg.add(pt: pointType)
                }
            }
            if(pg.pointValue != 0){
                pointGroups.append(pg)
            }
        }
        return pointGroups
    }
    
    func createUser(onDone:@escaping (_ err:Error?)->Void ){
        fbh.createUser(onDone: onDone)
    }
    
    func getUserWhenLogginIn(id:String, onDone:@escaping (_ success:Bool) ->Void ){
        fbh.getUserWhenLogIn(id: id, onDone: onDone)
    }
    
    func refreshPointGroups(onDone:@escaping ([PointGroup])-> Void) {
        fbh.retrievePointTypes(onDone: {(pointTypes:[PointType]) in
            self._pointTypes = pointTypes
            self._pointGroups = self.sortIntoPointGroupsWithPermission(arr: pointTypes)
            onDone(self._pointGroups!)
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

    func getUserRefFromUserID(id:String) -> DocumentReference {
        return fbh.getDocumentReferenceFromID(id: id)
    }
    
    func createQRCode(link:Link, onDone:@escaping(_ id:String?)->Void){
        fbh.createQRCode(link: link, onDone: onDone)
    }
    
    func handlePointLink(id:String){
        fbh.findLinkWithID(id: id, onDone: {(linkOptional:Link?) in
            guard let link = linkOptional else {
                let banner = NotificationBanner(title: "Failure", subtitle: "Could not submit points.", style: .danger)
                banner.duration = 2
                banner.show()
                return
            }
            let pointType = self.getPointType(value: link.pointTypeID)
            let resident = User.get(.name) as! String
            let floorID = User.get(.floorID) as! String
            let ref = self.getUserRefFromUserID(id: User.get(.id) as! String)
            let log = PointLog(pointDescription: link.description, resident: resident, type: pointType, floorID: floorID, residentRef: ref)
            var documentID = ""
            if(link.singleUse){
                documentID = id
            }
            self.fbh.addPointLog(log: log, documentID: documentID, preApproved: true, onDone: {(err:Error?) in
                if(err == nil){
                    let banner = NotificationBanner(title: "Success", subtitle: "The point in the link was recorded.", style: .success)
                    banner.duration = 2
                    banner.show()
                    
                }
                else{
                    let banner = NotificationBanner(title: "Failure", subtitle: "Could not submit points due to server error.", style: .danger)
                    banner.duration = 2
                    banner.show()
                }
            })
            
        })
    }
    
    func getQRCodeFor(ownerID:String, withRefresh refresh:Bool, withCompletion onDone:@escaping ( _ links:[Link]?)->Void){
        if(refresh || self._links == nil){
            fbh.getQRCodeFor(ownerID: ownerID, withCompletion: {(links:[Link]?) in
                self._links = links
                onDone(links)
            })
        }
        else{
            onDone(self._links)
        }
    }
    
    func setLinkActivation(link:Link, withCompletion onDone:@escaping ( _ err:Error?) ->Void){
        fbh.setLinkActivation(link: link, withCompletion: onDone)
    }
}


//class DataManager {
//
//    func retrievePointTypes() -> [PointGroup] {
//        return nil;
//    }
//}
