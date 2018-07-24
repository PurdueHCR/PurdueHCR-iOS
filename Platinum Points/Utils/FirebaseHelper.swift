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
        db.collection("Users").document(User.get(.id) as! String).setData([
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
        let docRef = db.collection("Users").document(id)
        
        docRef.getDocument { (document, error) in
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
    func addPointLog(log:PointLog, onDone:@escaping (_ err:Error?)->Void){
        let house = User.get(.house) as! String// crash here becasue user. hosue is null
        var ref: DocumentReference? = nil
        // write the document to the HOUSE table and save the reference
        ref = self.db.collection(self.HOUSE).document(house).collection(self.POINTS).addDocument(data: [
            "Description" : log.pointDescription as Any,
            "PointTypeID" : ( log.type.pointID * -1) as Any,
            "Resident"    : log.resident as Any,
            FLOOR_ID      : log.floorCode as Any
        ]){ err in
            if ( err == nil){
                let userID = User.get(.id) as! String
                //add a document to the table for the user with the reference to the point
                self.db.collection(self.USERS).document(userID).collection("Points").document(ref!.documentID).setData(["Point":ref!])
                {err in
                    onDone(err)
                }
            }
            else{
                onDone(err)
            }
        }
    }
    
    func approvePoint(log:PointLog, approved:Bool, onDone:@escaping (_ err:Error?)->Void){
        let house = User.get(.house) as! String
        var housePointRef: DocumentReference?
        var userPointRef: DocumentReference?
        var houseRef:DocumentReference?
        var userRef:DocumentReference?
        houseRef = self.db.collection(self.HOUSE).document(house)
        housePointRef = houseRef!.collection(self.POINTS).document(log.logID!)
        userRef = self.db.collection(self.USERS).document(User.get(.id) as! String)
        userPointRef = userRef!.collection(self.POINTS).document(log.logID!)
        if(approved){
            let value = log.type.pointID
            housePointRef!.updateData(["PointTypeID":value as Any])
            let houseRef = self.db.collection(self.HOUSE).document(house)
            let userRef = self.db.collection(self.USERS).document(User.get(.id) as! String)
            
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
        else{
            housePointRef?.delete(){ err in
                if let err = err {
                    print("Error removing HousePoint: \(err)")
                } else {
                    print("housePoint successfully removed!")
                }
            }
            userPointRef?.delete(){ err in
                if let err = err {
                    print("Error removing userPoint: \(err)")
                } else {
                    print("userPoint successfully removed!")
                }
            }
        }
    }
    
    
    func getUnconfirmedPoints(onDone:@escaping ( _ pointLogs:[PointLog])->Void)
    {
        let house = User.get(.house) as! String
        let docRef = db.collection(self.HOUSE).document(house).collection(self.POINTS)
        let userFloorCode = User.get(.floorID) as! String
        
        docRef.whereField("PointTypeID", isLessThan: 0).getDocuments()
            { (querySnapshot, error) in
                if error != nil {
                    print("Error getting documenbts: \(String(describing: error))")
                    return
                }
                var pointLogs = [PointLog]()
                for document in querySnapshot!.documents {
                    let floorCode = document.data()["FloorID"] as! String
                    // The reason I check this here instead of in the query is because Firestore does not support,
                    // at the time of writing, the ability to query the data on more than one field. :(
                    if(floorCode == userFloorCode){
                        let id = document.documentID
                        let description = document.data()["Description"] as! String
                        let idType = (document.data()["PointTypeID"] as! Int) * -1
                        let resident = document.data()["Resident"] as! String
                        let pointType = DataManager.sharedManager.getPointType(value: idType)
                        let pointLog = PointLog(pointDescription: description, resident: resident, type: pointType, floorCode: floorCode)
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
    
    func refreshHouseInformation(onDone:@escaping ( _ houses:[House])->Void){
        let houseRef = self.db.collection(self.HOUSE)
        houseRef.getDocuments() { (querySnapshot, err) in
            var houseArray = [House]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for houseDocument in querySnapshot!.documents
                {
                    let points = houseDocument.data()[self.TOTAL_POINTS] as! Int
                    let hex = houseDocument.data()["Color"] as! String
                    let id = houseDocument.documentID
                    houseArray.append(House(id: id, points: points, hexColor:hex))
                }
                houseArray.sort(by: {$0.totalPoints > $1.totalPoints})
                onDone(houseArray)
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
    
    
    
}

