//
//  FirebaseHelper.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/9/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import Firebase


class FirebaseHelper {
    
    let db: Firestore
    let storage: Storage
    let NAME = "Name"
    let PERMISSION_LEVEL = "Permission Level"
    let HOUSE = "House"
    let POINTS = "Points"
    let USERS = "Users"
    let TOTAL_POINTS = "TotalPoints"
    let FLOOR_ID = "FloorID"

    
    init(){
        db = Firestore.firestore()
        storage = Storage.storage()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    //assume that user is saved in cely
    func createUser(onDone:@escaping (_ err: Error?) -> Void){
        let userRef = db.collection("Users").document(User.get(.id) as! String)
        userRef.setData([
            self.NAME: User.get(.name)!,
            self.PERMISSION_LEVEL: User.get(.permissionLevel)!,
            self.HOUSE:User.get(.house)!,
            self.FLOOR_ID:User.get(.floorID)!,
            self.TOTAL_POINTS:0
        ]){ err in
            onDone(err)
        }
    }
    
    func sortPointArray(arr:[PointType]) -> [PointGroup]{
        var pointGroup = [PointGroup]()
        if(!arr.isEmpty){
            var value = arr[0].pointValue
            var pg = PointGroup(val:value)
            pointGroup.append(pg)
            pg.add(pt: arr[0])
            for i in 1..<arr.count {
                if(arr[i].pointValue == value){
                    pg.add(pt: arr[i])
                }
                else{
                    value = arr[i].pointValue
                    pg = PointGroup(val:value)
                    pointGroup.append(pg)
                    pg.add(pt: arr[i])
                }
            }
            
        }
        return pointGroup
    }
    
    
    func retrievePointTypes(onDone:@escaping ([PointGroup])->Void) {
        self.db.collection("PointTypes").getDocuments() { (querySnapshot, err) in
            var pointArray = [PointType]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for pointDocument in querySnapshot!.documents
                {
                    let description = pointDocument.data()["Description"] as! String
                    let residentSubmit = pointDocument.data()["ResidentsCanSubmit"] as! Bool
                    let value = pointDocument.data()["Value"] as! Int
                    let id = Int(pointDocument.documentID)
                    pointArray.append(PointType(pv: value, pd: description , rcs: residentSubmit, pid: id!))
                }
                pointArray.sort(by: {$0.pointValue < $1.pointValue})
                onDone(self.sortPointArray(arr: pointArray))
            }
        }
    }
    
    func getUserWhenLogIn(id:String, onDone:@escaping (_ success:Bool)->Void){
        let userRef = db.collection("Users").document(id)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                User.save(document.data()![self.HOUSE] as Any, as: .house)
                User.save(document.data()![self.FLOOR_ID] as Any, as: .floorID)
                User.save(document.data()![self.NAME] as Any, as: .name)
                User.save(document.data()![self.PERMISSION_LEVEL] as Any, as: .permissionLevel)
                User.save(document.data()![self.TOTAL_POINTS] as Any, as: .points)
                onDone(true)
            } else {
                print("Document does not exist")
                onDone(false)
            }
        }
    }
    
    // Write the point to the house points log and write the reference to the user
    // put in onDone to handle what happens when it returns
    func addPointLog(log:PointLog, documentID:String = "",preApproved:Bool = false, onDone:@escaping (_ err:Error?)->Void){
        let house = User.get(.house) as! String
        var ref: DocumentReference? = nil
        var multiplier = -1
        if(preApproved){
            multiplier = 1
        }
        if(documentID == "" )
        {
            // write the document to the HOUSE table and save the reference
            ref = self.db.collection(self.HOUSE).document(house).collection(self.POINTS).addDocument(data: [
                "Description" : log.pointDescription,
                "PointTypeID" : ( log.type.pointID * multiplier),
                "Resident"    : log.resident,
                "ResidentRef"  : log.residentRef,
                FLOOR_ID      : log.floorID as Any
            ]){ err in
                if ( err == nil){
                    //add a document to the table for the user with the reference to the point
                    log.residentRef.collection("Points").document(ref!.documentID).setData(["Point":ref!])
                    {err in
                        if(err == nil && preApproved)
                        {
                            self.updateHouseAndUserPoints(log: log, userRef: log.residentRef, houseRef: self.db.collection(self.HOUSE).document(house), onDone: onDone)
                        }
                        else{
                            onDone(err)
                        }
                    }
                }
                else{
                    onDone(err)
                }
            }
        }
        else
        {
            ref = self.db.collection(self.HOUSE).document(house).collection(self.POINTS).document(documentID)
            ref!.setData([
                "Description" : log.pointDescription,
                "PointTypeID" : ( log.type.pointID * multiplier),
                "Resident"    : log.resident,
                "ResidentRef"  : log.residentRef,
                FLOOR_ID      : log.floorID as Any
            ]){ err in
                if ( err == nil){
                    //add a document to the table for the user with the reference to the point
                    log.residentRef.collection("Points").document(ref!.documentID).setData(["Point":ref!])
                    {err in
                        if(err == nil && preApproved)
                        {
                            self.updateHouseAndUserPoints(log: log, userRef: log.residentRef, houseRef: self.db.collection(self.HOUSE).document(house), onDone: onDone)
                        }
                        else{
                            onDone(err)
                        }
                    }
                }
                else{
                    onDone(err)
                }
            }
        }
    }
    
    func approvePoint(log:PointLog, approved:Bool, onDone:@escaping (_ err:Error?)->Void){
        //TODO While User.get(house) will work for now, look at doing this a better way
        let house = User.get(.house) as! String
        var housePointRef: DocumentReference?
        var userPointRef: DocumentReference?
        var houseRef:DocumentReference?
        var userRef:DocumentReference?
        houseRef = self.db.collection(self.HOUSE).document(house)
        housePointRef = houseRef!.collection(self.POINTS).document(log.logID!)
        userRef = log.residentRef
        userPointRef = userRef!.collection(self.POINTS).document(log.logID!)
        if(approved){
            let value = log.type.pointID
            housePointRef!.updateData(["PointTypeID":value as Any])
            updateHouseAndUserPoints(log: log, userRef: userRef!, houseRef: houseRef!, onDone: {(err:Error?) in
                onDone(err)
            })
        }
        else{
            housePointRef?.delete(){ err in
                if err != nil {
                    print("Error removing HousePoint: \(err!)")
                    onDone(err)
                } else {
                    print("housePoint successfully removed!")
                    userPointRef?.delete(){ errDeep in
                        onDone(errDeep)
                    }
                }
            }
        }
    }
    
    
    func getUnconfirmedPoints(onDone:@escaping ( _ pointLogs:[PointLog])->Void)
    {
        let house = User.get(.house) as! String
        let docRef = db.collection(self.HOUSE).document(house).collection(self.POINTS)
        let userFloorID = User.get(.floorID) as! String
        
        docRef.whereField("PointTypeID", isLessThan: 0).getDocuments()
            { (querySnapshot, error) in
                if error != nil {
                    print("Error getting documenbts: \(String(describing: error))")
                    return
                }
                var pointLogs = [PointLog]()
                for document in querySnapshot!.documents {
                    let floorID = document.data()["FloorID"] as! String
                    // The reason I check this here instead of in the query is because Firestore does not support,
                    // at the time of writing, the ability to query the data on more than one field. :(
                    if(floorID == userFloorID){
                        let id = document.documentID
                        let description = document.data()["Description"] as! String
                        let idType = (document.data()["PointTypeID"] as! Int) * -1
                        let resident = document.data()["Resident"] as! String
                        let residentRefMaybe = document.data()["ResidentRef"]
                        var residentRef = self.db.collection(self.USERS).document("ypT6K68t75hqX6OubFO0HBBTHoy1")
                        if(residentRefMaybe != nil ){
                            residentRef = residentRefMaybe as! DocumentReference
                        }
                        let pointType = DataManager.sharedManager.getPointType(value: idType)
                        let pointLog = PointLog(pointDescription: description, resident: resident, type: pointType, floorID: floorID, residentRef:residentRef)
                        pointLog.logID = id
                        pointLogs.append(pointLog)
                    }
                }
                onDone(pointLogs)
                

        }
    }
    
    func refreshUserInformation(onDone:@escaping (_ err:Error?)->Void){
        let userRef = self.db.collection(self.USERS).document(User.get(.id) as! String)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                User.save(document.data()![self.HOUSE] as Any, as: .house)
                User.save(document.data()![self.FLOOR_ID] as Any, as: .floorID)
                User.save(document.data()![self.NAME] as Any, as: .name)
                User.save(document.data()![self.PERMISSION_LEVEL] as Any, as: .permissionLevel)
                User.save(document.data()![self.TOTAL_POINTS] as Any, as: .points)
                onDone(error)
            } else {
                print("Document does not exist")
                onDone(error)
            }
        }
    }
    
    func refreshHouseInformation(onDone:@escaping ( _ houses:[House],_ code:[HouseCode])->Void){
        let houseRef = self.db.collection(self.HOUSE)
        houseRef.getDocuments() { (querySnapshot, err) in
            var houseArray = [House]()
            var houseKeys = [HouseCode]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for houseDocument in querySnapshot!.documents
                {
                    let points = houseDocument.data()[self.TOTAL_POINTS] as! Int
                    let hex = houseDocument.data()["Color"] as! String
                    let id = houseDocument.documentID
                    
                    for key in houseDocument.data().keys
                    {
                        if(key.contains("Code"))
                        {
                            print("Append code: \(key)")
                            let floorID = key.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)[0]
                            let houseCode = houseDocument.data()[key] as! String
                            houseKeys.append(HouseCode(code: houseCode, house: id, floorID:String(floorID)))
                        }
                    }
                    houseArray.append(House(id: id, points: points, hexColor:hex))
                }
                houseArray.sort(by: {$0.totalPoints > $1.totalPoints})
                onDone(houseArray, houseKeys)
            }
        }
    }
    
    func refreshRewards(onDone:@escaping (_ rewards:[Reward])->Void ){
        self.db.collection("Rewards").getDocuments(){ (querySnapshot, err) in
            var rewardArray = [Reward]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for rewardDocument in querySnapshot!.documents
                {
                    let requiredPoints = rewardDocument.data()["RequiredValue"] as! Int
                    let fileName = rewardDocument.data()["FileName"] as! String
                    let name = rewardDocument.documentID
                    rewardArray.append(Reward(requiredValue: requiredPoints, fileName: fileName, rewardName: name))
                }
                rewardArray.sort(by: {$0.requiredValue < $1.requiredValue})
                onDone(rewardArray)
            }
        }
    }
    
    func retrievePictureFromFilename(filename:String,onDone:@escaping ( _ image:UIImage) ->Void ){
        let pathReference = storage.reference(withPath: filename)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
            } else {
                // Data for filename is returned
                onDone(UIImage(data: data!)!)
            }
        }
    }
    
    func getDocumentReferenceFromID(id:String) -> DocumentReference {
        return db.collection(self.USERS).document(id)
        
    }
    
    func findLinkWithID(id:String, onDone:@escaping (_ link:Link?)->Void){
        let linkRef = db.collection("Links").document(id)
        linkRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let descr = document.data()!["Description"] as! String
                let single = document.data()!["SingleUse"] as! Bool
                let pointID = document.data()!["PointID"] as! Int
                let link = Link(id: id, description: descr, singleUse: single, pointTypeID: pointID)
                onDone(link)
            } else {
                print("Document does not exist")
                onDone(nil)
            }
        }
    }
    
    func updateUserPoints(log:PointLog, userRef:DocumentReference,onDone:@escaping (_ err:Error?)->Void) {
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldTotal = userDocument.data()?["TotalPoints"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve TotalPoints from snapshot \(userDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            let newTotal = oldTotal + log.type.pointValue
            transaction.updateData(["TotalPoints": newTotal], forDocument: userRef)
            return nil
        })
        { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                onDone(error)
            } else {
                print("Transaction successfully committed!")
                onDone(nil)
            }
        }
    }
    
    func updateHousePoints(log:PointLog, houseRef:DocumentReference,onDone:@escaping (_ err:Error?)->Void)
    {
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let houseDocument: DocumentSnapshot
            do {
                try houseDocument = transaction.getDocument(houseRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldTotal = houseDocument.data()?["TotalPoints"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve TotalPoints from snapshot \(houseDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            let newTotal = oldTotal + log.type.pointValue
            transaction.updateData(["TotalPoints": newTotal], forDocument: houseRef)
            return nil
        })
        { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                onDone(error)
            } else {
                print("Transaction successfully committed!")
                onDone(nil)
            }
        }
    }
    
    func updateHouseAndUserPoints(log:PointLog,userRef:DocumentReference,houseRef:DocumentReference,onDone:@escaping (_ err:Error?)->Void)
    {
        updateHousePoints(log: log, houseRef: houseRef, onDone: {(err:Error?)in
            if(err != nil){
                onDone(err)
            }
            self.updateUserPoints(log: log, userRef: userRef, onDone: {(errDeep:Error?) in
                onDone(errDeep)
            })
        })
    }
    
}

