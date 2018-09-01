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
            self.PERMISSION_LEVEL: User.get(.permissionLevel)! as! Int,
            self.HOUSE:User.get(.house)!,
            self.FLOOR_ID:User.get(.floorID)!,
            self.TOTAL_POINTS:0
        ]){ err in
            onDone(err)
        }
    }
    

    func retrievePointTypes(onDone:@escaping ([PointType])->Void) {
        self.db.collection("PointTypes").getDocuments() { (querySnapshot, err) in
            var pointArray = [PointType]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for pointDocument in querySnapshot!.documents
                {
                    let id = Int(pointDocument.documentID)!
                    //Points with IDs greater than 1000 are just for REA/REC
                    if(id > 1000){
                        return;
                    }
                    let description = pointDocument.data()["Description"] as! String
                    let residentSubmit = pointDocument.data()["ResidentsCanSubmit"] as! Bool
                    let value = pointDocument.data()["Value"] as! Int
                    pointArray.append(PointType(pv: value, pd: description , rcs: residentSubmit, pid: id))
                }
                pointArray.sort(by: {
                    if($0.pointValue == $1.pointValue){
                        return $0.pointID < $1.pointID
                    }
                    else{
                        return $0.pointValue < $1.pointValue
                    }
                    
                })
                onDone(pointArray)
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
                User.save((document.data()![self.PERMISSION_LEVEL] as! Int) as Any, as: .permissionLevel)
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
                "ResidentReportTime" : Timestamp.init(),
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
            //Adding a point with a specific Document ID
            ref = self.db.collection(self.HOUSE).document(house).collection(self.POINTS).document(log.residentRef.documentID+documentID)
            ref!.getDocument { (document, error) in
                if let document = document, document.exists {
                    onDone(NSError(domain: "Document Exists", code: 1, userInfo: nil))
                } else {
                    ref!.setData([
                        "Description" : log.pointDescription,
                        "PointTypeID" : ( log.type.pointID * multiplier),
                        "Resident"    : log.resident,
                        "ResidentRef"  : log.residentRef,
                        self.FLOOR_ID      : log.floorID as Any
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
        }
    }
    
    func approvePoint(log:PointLog, approved:Bool, onDone:@escaping (_ err:Error?)->Void){
        //TODO While User.get(house) will work for now, look at doing this a better way
        let house = User.get(.house) as! String
        var housePointRef: DocumentReference?
        var houseRef:DocumentReference?
        var userRef:DocumentReference?
        houseRef = self.db.collection(self.HOUSE).document(house)
        housePointRef = houseRef!.collection(self.POINTS).document(log.logID!)
        userRef = log.residentRef
        let value = log.type.pointID
        var description = log.pointDescription
        if(!approved){
            description = "DENIED: "+description
        }
        //TODO: yes this is not entirely thread safe. If some future developer would be so kind as to make this more robust, this would be great
        //Note: The race conditions only happens with Firebase rn, so if in the future we switch to a different database solution, this may no longer be an issue
        housePointRef!.getDocument { (document, error) in
            //make sure that the document exists
            if let document = document, document.exists {
                //Make sure that no one has laready approved it.
                if((document.data()!["ApprovedBy"] as! String?) != nil){
                    // someone has already approved it :(
                    onDone(NSError(domain: "Document has already been approved", code: 1, userInfo: nil))
                    
                }
                else{
                    //It has not been approved yet, you are good to go
                    housePointRef!.setData(["PointTypeID":value,"ApprovedBy":User.get(.name) as! String,"ApprovedOn":Timestamp.init(), "Description":description],merge:true){err in
                        if(err == nil && approved){
                            self.updateHouseAndUserPoints(log: log, userRef: userRef!, houseRef: houseRef!, onDone: {(err:Error?) in
                                onDone(err)
                            })
                        }
                        else{
                            onDone(err)
                        }
                    }
                }
            } else {
                onDone(NSError(domain: "Document does not exist", code: 2, userInfo: nil))
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
                    if(userFloorID == "6N" || userFloorID == "6S"){
                        var otherCode = "6N"
                        if(userFloorID == "6N"){
                            otherCode = "6S"
                        }
                        if(floorID != otherCode){
                            let id = document.documentID
                            let description = document.data()["Description"] as! String
                            let idType = (document.data()["PointTypeID"] as! Int) * -1
                            var resident = document.data()["Resident"] as! String
                            if(floorID == "Shreve"){
                                resident = "(Shreve) "+resident
                            }
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
                    else{
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
                    let numberOfResidents = houseDocument.data()["NumberOfResidents"] as! Int
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
                    houseArray.append(House(id: id, points: points, hexColor:hex, numberOfResidents:numberOfResidents))
                }
                houseArray.sort(by: {$0.pointsPerResident > $1.pointsPerResident})
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
                let enabled = document.data()!["Enabled"] as! Bool
                let archived = document.data()!["Archived"] as! Bool
                let link = Link(id: id, description: descr, singleUse: single, pointTypeID: pointID,enabled:enabled,archived:archived)
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
    
    func createQRCode(link:Link,onDone:@escaping ( _ id:String?) -> Void){
        let ref = db.collection("Links")
        var linkID:DocumentReference?
        linkID = ref.addDocument(data: [
            "Description":link.description,
            "PointID":link.pointTypeID,
            "SingleUse":link.singleUse,
            "CreatorID":User.get(.id) as! String,
            "Enabled":link.enabled,
            "Archived":link.archived])
        {err in
            if(err == nil){
                onDone(linkID?.documentID)
            }
            else{
                onDone(nil)
            }
        }
    }
    
    func getQRCodeFor(ownerID:String,withCompletion onDone:@escaping ( _ links:[Link]?)->Void){
        db.collection("Links").whereField("CreatorID", isEqualTo: ownerID).getDocuments()
            { (querySnapshot, error) in
                if error != nil {
                    print("Error getting documenbts: \(String(describing: error))")
                    onDone(nil)
                }
                var links = [Link]()
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let descr = document.data()["Description"] as! String
                    let single = document.data()["SingleUse"] as! Bool
                    let pointID = document.data()["PointID"] as! Int
                    let enabled = document.data()["Enabled"] as! Bool
                    let archived = document.data()["Archived"] as! Bool
                    let link = Link(id: id, description: descr, singleUse: single, pointTypeID: pointID, enabled:enabled, archived:archived)
                    links.append(link)
                }
                onDone(links)
            }
    }
    
    func setLinkActivation(link:Link, withCompletion onDone:@escaping ( _ err:Error?) ->Void){
        db.collection("Links").document(link.id).updateData(["Enabled":link.enabled]){err in
            onDone(err)
        }
    }
    func setLinkArchived(link:Link, withCompletion onDone:@escaping ( _ err:Error?) ->Void){
        db.collection("Links").document(link.id).updateData(["Archived":link.archived]){err in
            onDone(err)
        }
    }
    
}

