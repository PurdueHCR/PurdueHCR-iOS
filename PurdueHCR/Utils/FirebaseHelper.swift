//
//  FirebaseHelper.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/9/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import NotificationBannerSwift


class FirebaseHelper {
    
    let db: Firestore
    let storage: Storage
    let FIRST_NAME = "FirstName"
	let LAST_NAME = "LastName"
    let PERMISSION_LEVEL = "Permission Level"
    let HOUSE = "House"
	let HOUSE_CODE = "HouseCodes"
    let POINTS = "Points"
    let USERS = "Users"
    let TOTAL_POINTS = "TotalPoints"
    let FLOOR_ID = "FloorID"
	let USER_ID = "UserID"
	let MESSAGES = "Messages"
    
    //----- LOCAL URLS ------//
//    let CREATE_QR_LINK = "https://localhost:5001/purdue-hcr-test/us-central1/link/create"
//    let HANDLE_URL = "http://localhost:5001/purdue-hcr-test/us-central1/point_log/handle"
//    let RANK_URL = "http://localhost:5001/purdue-hcr-test/us-central1/user/auth-rank"
//    let SUBMIT_URL = "http://localhost:5001/purdue-hcr-test/us-central1/user/submitPoint"
//    let ADD_MESSAGE_URL = "http://localhost:5001/purdue-hcr-test/uscentral1/point_log/messages"
//    let GET_EVENT_URL = "http://localhost:5001/purdue-hcr-test/us-central1/event/feed"
//    let ADD_EVENT_URL = "http://localhost:5001/purdue-hcr-test/us-central1/event/"
//    let UPDATE_POINT_LOG_TYPE_URL = "http://localhost:5001/purdue-hcr-test/uscentral1/point_log/updateSubmissionPointType"
//    let GET_POINT_LOG_BY_ID_URL = "http://localhost:5001/purdue-hcr-test/uscentral1/point_log/getPointLogById"
    
    //----- TEST URLS ------//
    let CREATE_QR_LINK = "https://us-central1-purdue-hcr-test.cloudfunctions.net/link/create"
    let HANDLE_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/point_log/handle"
    let RANK_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/user/auth-rank"
    let SUBMIT_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/user/submitPoint"
    let ADD_MESSAGE_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/point_log/messages"
    let GET_EVENT_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/event/feed"
    let ADD_EVENT_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/event/"
    let GRANT_AWARD_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/competition/houseAward"
    let UPDATE_POINT_LOG_TYPE_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/point_log/updateSubmissionPointType"
    let GET_POINT_LOG_BY_ID_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/point_log/getPointLogById"
    let CREATE_REWARD_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/rewards/"
    let UPDATE_REWARD_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/rewards/"
    let DELETE_REWARD_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/rewards/"
    

//    ----- TEST URLS ------//
//    let CREATE_QR_LINK = "https://us-central1-purdue-hcr-test.cloudfunctions.net/link/create"
//    let HANDLE_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/point_log/handle"
//    let RANK_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/user/auth-rank"
//    let SUBMIT_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/user/submitPoint"
//    let ADD_MESSAGE_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/point_log/messages"
//    let GET_EVENT_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/event/feed"
//    let ADD_EVENT_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/event/"
//    let GRANT_AWARD_URL = "https://us-central1-purdue-hcr-test.cloudfunctions.net/competition/houseAward"
    //    let CREATE_REWARD_URL = ""
    //    let UPDATE_REWARD_URL = ""
    //    let DELETE_REWARD_URL = ""
    
    
    init() {
        db = Firestore.firestore()
        storage = Storage.storage()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // Assume that user is saved in cely
    func createUser(onDone:@escaping (_ err: Error?) -> Void){
        let userRef = db.collection("Users").document(User.get(.id) as! String)
        userRef.setData([
            self.FIRST_NAME: User.get(.firstName)!,
			self.LAST_NAME: User.get(.lastName)!,
            self.PERMISSION_LEVEL: User.get(.permissionLevel)! as! Int,
            self.HOUSE:User.get(.house)!,
            self.FLOOR_ID:User.get(.floorID)!,
            self.TOTAL_POINTS:0,
			self.USER_ID:User.get(.id)!
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
					let name = pointDocument.data()["Name"] as! String
                    let description = pointDocument.data()["Description"] as! String
                    let residentSubmit = pointDocument.data()["ResidentsCanSubmit"] as! Bool
                    let value = pointDocument.data()["Value"] as! Int
                    let permissionLevel = pointDocument.data()["PermissionLevel"] as! Int
                    let isEnabled = pointDocument.data()["Enabled"] as! Bool
					pointArray.append(PointType(pv: value, pn: name, pd: description , rcs: residentSubmit, pid: id, permissionLevel: PointType.PermissionLevel(rawValue: permissionLevel)!, isEnabled:isEnabled))
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
                let permissionLevel = document.data()![self.PERMISSION_LEVEL] as! Int
                User.save(permissionLevel as Any, as: .permissionLevel)
                User.save(document.data()![self.FIRST_NAME] as Any, as: .firstName)
				User.save(document.data()![self.LAST_NAME] as Any, as: .lastName)
                if(permissionLevel == 2){ // check if REA/REC
                    
                }
                else{
                    User.save(document.data()![self.HOUSE] as Any, as: .house)
                    User.save(document.data()![self.FLOOR_ID] as Any, as: .floorID)
                    //User.save((document.data()![self.PERMISSION_LEVEL] as! Int) as Any, as: .permissionLevel)
                    User.save(document.data()![self.TOTAL_POINTS] as Any, as: .points)
                }
                onDone(true)
            } else {
                print("Document does not exist")
                onDone(false)
            }
        }
    }
    

    /// Adds Point Log submission to the Database
    ///
    /// - Parameters:
    ///   - log: Point Log that is to be added to the database
    ///   - documentID: specified id for Point Log in the database (Used for Single Use Qr codes)
    ///   - preApproved: Boolean that denotes whether the Log can skip RHP approval or not.
    ///   - house: If the house is different than the saved house for the user (Used for REC Awarding points)
    ///   - isRECGrantingAward: Boolean to denote that this point is being added by the RHP
    ///   - onDone: Closure function the be called once the code hits an error or finishs. err is nil if no errors are found.
    func addPointLog(log:PointLog, documentID:String = "", preApproved:Bool = false, house:String = (User.get(.house) as! String), isRECGrantingAward:Bool = false, onDone: @escaping (_ err:Error?)->Void){
        var ref: DocumentReference? = nil
        //If point type is disabled and it is not an REC granting an award, warn that it is disabled
        if(!log.type.isEnabled && !isRECGrantingAward){
            onDone(NSError(domain: "Could not submit points because point type is disabled.", code: 1, userInfo: nil))
            return
        }
        //If the log is preapproved, update the approval status
        if(preApproved){
            log.updateApprovalStatus(approved: preApproved, preapproved: preApproved)
        }
        
        if(documentID == "")
        {
//            // write the document to the HOUSE table and save the reference
//			let data = log.convertToDict()
//			var ref: DocumentReference? = nil
//			ref = self.db.collection(self.HOUSE).document(house).collection(self.POINTS).addDocument(data: data, completion: { err in
//                if ( err == nil){
//					if (preApproved) {
//						//OnDone will be called in updateHouseAndUserPoints
//						self.updateHouseAndUserPoints(log: log, residentID: log.residentId, houseRef: self.db.collection(self.HOUSE).document(house), isRECGrantingAward:isRECGrantingAward, updatePointValue: false, onDone: onDone)
//                        //Add message to pointLog does not require us to wait
//						self.addMessageToPontLog(message: "Pre-approved by PurdueHCR", messageType: .approve, pointID: ref!.documentID)
//					}
//                    else{
//                        onDone(nil)
//                    }
//				} else{
//                    onDone(err)
//                }
//			})
            
            DataManager.sharedManager.getAuthorizationToken { (token, err) in
                if let err = err {
                    onDone(err)
                } else {
                    let headerVal = "Bearer " + (token!)
                    let header = HTTPHeader(name: "Authorization", value: headerVal)
                    let headers = HTTPHeaders(arrayLiteral: header)
                    let url = URL(string: self.SUBMIT_URL)!
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let date = dateFormatter.string(from: (log.dateOccurred?.dateValue())!)
                    let parameters = ["point_type_id":log.type.pointID, "description":log.pointDescription, "date_occurred":date] as [String : Any]
                    
                    AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                        switch response.result {
                        case .success:
                            if (preApproved) {
                                var endText = " points submitted."
                                if (log.type.pointValue == 1) {
                                    endText = " point submitted."
                                }
                                let banner = NotificationBanner(title: "Way to Go RHP", subtitle: "Congrats, \(log.type.pointValue)" + endText, style: .success)
                                banner.duration = 2
                                banner.show()
                            }
                            else {
                                let banner = NotificationBanner(title: "Submitted for approval!", subtitle: log.pointDescription, style: .success)
                                banner.duration = 2
                                banner.show()
                            }
                            onDone(nil)
                        case .failure(let error):
                            if (error.localizedDescription == "The operation couldn’t be completed. (Could not submit points because point type is disabled. error 1.)"){
                                DispatchQueue.main.async {
                                    let banner = NotificationBanner(title: "Could not submit.", subtitle: "This type of point is disabled for now.", style: .danger)
                                    banner.duration = 2
                                    banner.show()
                                }
                            } else if (error.localizedDescription == "The operation couldn’t be completed. (Document Exists error 1.)"){
                                DispatchQueue.main.async {
                                    let banner = NotificationBanner(title: "Could not submit.", subtitle: "You have already scanned this code.", style: .danger)
                                    banner.duration = 2
                                    banner.show()
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    let banner = NotificationBanner(title: "Failure", subtitle: "Could not submit points due to server error.", style: .danger)
                                    banner.duration = 2
                                    banner.show()
                                }
                            }
                            onDone(error)
                        }
                    }
                }
            }
        }
        else
        {
            //Adding a point with a specific Document ID
            ref = self.db.collection(self.HOUSE).document(house).collection(self.POINTS).document(documentID)//log.residentRef.documentID+documentID)
            ref!.getDocument { (document, error) in
                if let document = document, document.exists {
                    // failure(NSError(domain: "Document Exists", code: 1, userInfo: nil)) HANDLE ERROR
                    let banner = NotificationBanner(title: "Failure", subtitle: "Point has already been submitted.", style: .danger)
                    banner.duration = 2
                    banner.show()
                } else {
                    ref!.setData(log.convertToDict()) { err in
                        if ( err == nil){
							if(preApproved)
							{
                                self.updateHouseAndUserPoints(log: log, residentID: log.residentId, houseRef: self.db.collection(self.HOUSE).document(house), isRECGrantingAward: isRECGrantingAward, updatePointValue: false) { (error) in
                                    if (error == nil) {
                                        var endText = " points submitted."
                                        if (log.type.pointValue == 1) {
                                            endText = " point submitted."
                                        }
                                        let banner = NotificationBanner(title: "Way to Go", subtitle: "Congrats, \(log.type.pointValue)" + endText,  style: .success)
                                        banner.duration = 2
                                        banner.show()
                                    } else {
                                        let banner = NotificationBanner(title: "Failure", subtitle: "Could not submit points due to server error.", style: .danger)
                                        banner.duration = 2
                                        banner.show()
                                    }
                                }
							}
							else {
                                let banner = NotificationBanner(title: "Way to Go", subtitle: "Congrats, \(log.type.pointValue) points submitted.", style: .success)
                                banner.duration = 2
                                banner.show()
								onDone(nil)
							}
                        }
                        else{
                            onDone(error)
                        }
                    }
                }
            }
        }
    }
    
    func sendSubmitPointRequest(log:PointLog, documentID:String = "", preApproved:Bool = false, house:String = (User.get(.house) as! String), isRECGrantingAward:Bool = false, token:String, success: (_ response: AnyObject?) -> Void, failure: (_ error: Error?) -> Void) {
        //
    }
    
    /// update the status of the point log if it has been approved, rejected, or updated
    ///
    /// - Parameters:
    ///   - log: Log that is being updated
    ///   - approved: BOOL: Approved (true) rejected(false)
    ///   - updating: Bool: If the log has already been approved or rejected, and you are changing that status, set updating to true
    ///   - onDone: Closure to handle when the function is finished or if there is an error
    func updatePointLogStatus(log:PointLog, approved:Bool, message: String = "", onDone:@escaping (_ err:Error?)->Void) {
        
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                onDone(err)
            } else {
                let headerVal = "Bearer " + (token!)
                let header = HTTPHeader(name: "Authorization", value: headerVal)
                let headers = HTTPHeaders(arrayLiteral: header)
                let url = URL(string: self.HANDLE_URL)!
                var parameters = ["approve":approved.description, "point_log_id":log.logID!] as [String : Any]
                
                if (!approved) {
                    parameters["message"] = message
                }
                
                AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        onDone(nil)
                    case .failure(let error):
                        print(error.localizedDescription)
                        onDone(error)
                    }
                }
            }
        }
        
    }
    
    /// update the point type id of a point log
    ///
    /// - Parameters:
    ///   - pointLogID: id of log to update
    ///   - newPointTypeID: id of the new point type for the log
    func updatePointLogPointTypeId(pointLogID: String, newPointTypeID: Int, onDone: @escaping (_ err:Error?)->Void) {
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                let banner = NotificationBanner(title: "Failure", subtitle: "Could not update the point log's point type.", style: .danger)
                banner.duration = 2
                banner.show()
                onDone(err)
            } else {
                
                let headers = self.generateHTTPHeader(token: token!)
                let url = URL(string: self.UPDATE_POINT_LOG_TYPE_URL)!
                let parameters = ["log_id":pointLogID, "new_point_type_id":newPointTypeID] as [String : Any]
                AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        onDone(nil)
                    case .failure(let error):
                        print(error.localizedDescription)
                        let banner = NotificationBanner(title: "Failure", subtitle: "Could not update the point log's point type.", style: .danger)
                        banner.duration = 2
                        banner.show()
                        onDone(error)
                    }
                }
            }
        }
    }
	
	/// Retrives the points that have been previously resolved
	///
	/// - Parameter onDone: returns pointLogs
	func getResolvedPoints(onDone: @escaping ( _ pointLogs:[PointLog])->Void) {
		let house = User.get(.house) as! String
		let docRef = db.collection(self.HOUSE).document(house).collection(self.POINTS)
		let userFloorID = User.get(.floorID) as! String
		
		docRef.whereField("PointTypeID", isGreaterThan: 0).getDocuments() { (querySnapshot, error) in
			if error != nil {
				print("Error getting documents: \(String(describing: error))")
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
						let pointLog = PointLog(id: id, document: document.data())
						pointLogs.append(pointLog)
					}
				}
				else{
					if(floorID == userFloorID){
						let id = document.documentID
						let pointLog = PointLog(id: id, document: document.data())
						pointLogs.append(pointLog)
					}
				}
			}
			onDone(pointLogs)
		}
	}
	
    func getUnconfirmedPoints(onDone:@escaping ( _ pointLogs:[PointLog])->Void) {
        let house = User.get(.house) as! String
        let docRef = db.collection(self.HOUSE).document(house).collection(self.POINTS)
        let userFloorID = User.get(.floorID) as! String
        
        docRef.whereField("PointTypeID", isLessThan: 0).whereField("FloorID", isEqualTo: userFloorID).getDocuments() { (querySnapshot, error) in
                if error != nil {
                    print("Error getting documents: \(String(describing: error))")
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
                            let pointLog = PointLog(id: id, document: document.data())
                            pointLogs.append(pointLog)
                        }
                    }
                    else{
                        if(floorID == userFloorID){
                            let id = document.documentID
                            let pointLog = PointLog(id: id, document: document.data())
                            pointLogs.append(pointLog)
                        }
                    }
                }
                onDone(pointLogs)
        }
    }
	
	func getMessagesForPointLog(pointLog: PointLog, onDone:@escaping ( _ messageLogs:[MessageLog])->Void) {
		let house = User.get(.house) as! String
		let pointID = pointLog.logID! as String
		let docRef = self.db.collection(self.HOUSE).document(house).collection(self.POINTS).document(pointID)
		
		// Error handling for if there are no messages.....
		
		docRef.collection(self.MESSAGES).getDocuments(completion: { (querySnapshot, error) in
			if error != nil {
				print("Error getting messages: \(String(describing: error))")
				return
			}
			var messageLogs = [MessageLog]()
			for document in querySnapshot!.documents {
				let creationDate = document.data()["CreationDate"] as! Timestamp
				let message = document.data()["Message"] as! String
				let senderFirstName = document.data()["SenderFirstName"] as! String
				let senderLastName = document.data()["SenderLastName"] as! String
				let senderPermissionLevel = PointType.PermissionLevel(rawValue: document.data()["SenderPermissionLevel"] as! Int)!
				let messageType = document.data()["MessageType"] as! String
				let log = MessageLog(creationDate: creationDate, message: message, senderFirstName: senderFirstName, senderLastName: senderLastName, senderPermissionLevel: senderPermissionLevel, messageType: MessageLog.MessageType(rawValue: messageType)!)
				messageLogs.append(log)
			}
			onDone(messageLogs)
		})
		
		let permissionLevel = PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)!
		if (permissionLevel == .resident) {
			docRef.setData(["ResidentNotifications": 0], merge: true)
		}
		else if (permissionLevel == .rhp) {
			docRef.setData(["RHPNotifications": 0], merge: true)
		}
	}
	
    func addMessageToPontLog(message: String, pointID: String, onDone: @escaping (_ err: Error?)->Void) {
	
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                DispatchQueue.main.async {
                    let banner = NotificationBanner(title: "Could not send message.", subtitle: "A server error occurred.", style: .danger)
                    banner.duration = 2
                    banner.show()
                }
                onDone(err)
            } else {
                let headerVal = "Bearer " + (token!)
                let header = HTTPHeader(name: "Authorization", value: headerVal)
                let headers = HTTPHeaders(arrayLiteral: header)
                let url = URL(string: self.ADD_MESSAGE_URL)!
                let parameters = ["log_id":pointID, "message":message] as [String : Any]
                
                AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        onDone(nil)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            let banner = NotificationBanner(title: "Could not send message.", subtitle: "A server error occurred.", style: .danger)
                            banner.duration = 2
                            banner.show()
                        }
                        onDone(error)
                    }
                }
            }
        }
        
//        let house = User.get(.house) as! String
//		let firstName = User.get(.firstName) as! String
//		let lastName = User.get(.lastName) as! String
//		let permissionLevel = PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)!
//		let newMessage = MessageLog.init(creationDate: Timestamp.init(), message: message, senderFirstName: firstName, senderLastName: lastName, senderPermissionLevel: permissionLevel, messageType: messageType)
//		let data = newMessage.convertToDict()
//		let ref = self.db.collection(self.HOUSE).document(house).collection(self.POINTS).document(pointID)
//		ref.collection(self.MESSAGES).addDocument(data: data)
//		var resNotif = 0
//		var rhpNotif = 0
//		ref.getDocument { (document, err) in
//			if (err != nil) {
//				print("Error getting document: \(String(describing: err))")
//				return
//			}
//			resNotif = document!.data()!["ResidentNotifications"] as! Int
//			rhpNotif = document!.data()!["RHPNotifications"] as! Int
//			if (permissionLevel == .resident) {
//				ref.setData(["RHPNotifications":(rhpNotif + 1)], merge: true)
//			}
//			else if (permissionLevel == .rhp && document?.data()!["ResidentId"] as! String != User.get(.id) as! String) {
//				ref.setData(["ResidentNotifications":(resNotif + 1)], merge: true)
//			}
//		}
		
	}
    
    func getPointLogByID(pointLogID: String, onDone:@escaping (_ pointLog:PointLog?, _ err:Error?)->Void) {
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                onDone(nil, err)
            } else {
                let headers = self.generateHTTPHeader(token: token!)
                let url = URL(string: self.GET_POINT_LOG_BY_ID_URL)!
                let parameters = ["log_id":pointLogID] as [String : Any]
                AF.request(url, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        if let val = response.value as? [String : Any] {
                            let log = val["pointLog"] as! [String:Any]
                            onDone(PointLog(id: pointLogID, data: log), nil)
                        } else {
                            onDone(nil, nil)
                        }
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        onDone(nil, error)
                    }
                }
            }
        }
    }
    
    func refreshUserInformation(onDone:@escaping (_ err:Error?)->Void){
        let userRef = self.db.collection(self.USERS).document(User.get(.id) as! String)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                User.save(document.data()![self.HOUSE] as Any, as: .house)
                User.save(document.data()![self.FLOOR_ID] as Any, as: .floorID)
                User.save(document.data()![self.FIRST_NAME] as Any, as: .firstName)
				User.save(document.data()![self.LAST_NAME] as Any, as: .lastName)
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
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for houseDocument in querySnapshot!.documents
                {
                    let points = houseDocument.data()[self.TOTAL_POINTS] as! Int
                    let hex = houseDocument.data()["Color"] as! String
                    let id = houseDocument.documentID
					let numResidents = houseDocument.data()["NumberOfResidents"] as! Int
                    houseArray.append(House(id: id, points: points, hexColor:hex, numResidents: numResidents))
                }
                houseArray.sort(by: {$0.getPPR() > $1.getPPR()})
				
            }
			
			let houseCodeRef = self.db.collection(self.HOUSE_CODE)
			houseCodeRef.getDocuments { (querySnapshot, err) in
				var houseCodes = [HouseCode]()
				if err != nil {
					print("Error getting documents: \(String(describing: err))")
				}
				for codeDoc in querySnapshot!.documents {
					let code = codeDoc.data()["Code"] as! String
					let codeName = codeDoc.data()["CodeName"] as! String
					let permissionLevel = codeDoc.data()["PermissionLevel"] as! Int
					let house = codeDoc.data()["House"]
					let floorID = codeDoc.data()["FloorId"]
                    houseCodes.append(HouseCode.init(code: code, codeName: codeName, permissionLevel: permissionLevel, house: house as? String ?? "", floorID: floorID as? String ?? ""))
					
                }
				onDone(houseArray, houseCodes)
			}
			
        }

    }
	
	// TODO: Make rewards a const
    func refreshRewards(onDone:@escaping (_ rewards:[Reward])->Void ){
        self.db.collection("Rewards").getDocuments(){ (querySnapshot, err) in
            var rewardArray = [Reward]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for rewardDocument in querySnapshot!.documents
                {
                    let downloadURL = rewardDocument.data()["DownloadURL"] as! String
                    let requiredPPR = rewardDocument.data()["RequiredPPR"] as! Int
                    let fileName = rewardDocument.data()["FileName"] as! String
                    let name = rewardDocument.data()["Name"] as! String
                    rewardArray.append(Reward(requiredPPR: requiredPPR, fileName: fileName, rewardName: name, downloadURL: downloadURL, id: rewardDocument.documentID))
                }
                rewardArray.sort(by: {$0.requiredPPR < $1.requiredPPR})
                onDone(rewardArray)
            }
        }
    }
    
    func retrievePictureFromFilename(filename:String,onDone:@escaping ( _ image:UIImage) ->Void ){
        let pathReference = storage.reference(withPath: filename)
        // Download in memory with a maximum allowed size of 100MB (100 * 1024 * 1024 bytes)
        pathReference.getData(maxSize: 20 * 1024 * 1024) { data, error in
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
                let id = document.documentID
                let archived = document.data()!["Archived"] as! Bool
                let claimedCount = document.data()!["ClaimedCount"] as! Int
                let creatorID = document.data()!["CreatorID"] as! String
                let descr = document.data()!["Description"] as! String
                let dyLink = document.data()!["DynamicLink"] as! String
                let enabled = document.data()!["Enabled"] as! Bool
                let pointID = document.data()!["PointID"] as! Int
                let pointDesc = document.data()!["PointTypeDescription"] as! String
                let pointName = document.data()!["PointTypeName"] as! String
                let pointVal = document.data()!["PointTypeValue"] as! Int
                let single = document.data()!["SingleUse"] as! Bool
                let link = Link(id: id, dynamicLink: dyLink, description: descr, singleUse: single, pointTypeID: pointID, pointTypeName: pointName, pointTypeDescription: pointDesc, pointTypeValue:pointVal, creatorID: creatorID, enabled:enabled, archived:archived, claimedCount: claimedCount)
                onDone(link)
            } else {
                print("Document does not exist")
                onDone(nil)
            }
        }
    }
    
    /// Grant an award to ahouse
    /// - Parameters:
    ///   - house: house to give the points
    ///   - ppr: the points per resident that the house should get
    ///   - description: description of the award
    func grantAward( ppr:Int, house:House, description:String, onDone: @escaping (_ err:Error?)->Void){
        
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                onDone(err)
            } else {
                
                let headers = self.generateHTTPHeader(token: token!)
                let url = URL(string: self.GRANT_AWARD_URL)!
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//                let date = dateFormatter.string(from: (log.dateOccurred?.dateValue())!)
                
                let parameters = ["house":house.houseID, "ppr":ppr, "description":description] as [String : Any]
                
                AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        onDone(nil)
                    case .failure(let error):
                        if (error.localizedDescription == "The operation couldn’t be completed. (Could not submit points because point type is disabled. error 1.)"){
                            DispatchQueue.main.async {
                                let banner = NotificationBanner(title: "Could not submit.", subtitle: "This type of point is disabled for now.", style: .danger)
                                banner.duration = 2
                                banner.show()
                            }
                        } else if (error.localizedDescription == "The operation couldn’t be completed. (Document Exists error 1.)"){
                            DispatchQueue.main.async {
                                let banner = NotificationBanner(title: "Could not submit.", subtitle: "You have already scanned this code.", style: .danger)
                                banner.duration = 2
                                banner.show()
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                let banner = NotificationBanner(title: "Failure", subtitle: "Could not submit points due to server error.", style: .danger)
                                banner.duration = 2
                                banner.show()
                            }
                        }
                        onDone(error)
                    }
                }
            }
        }
    }
    
    /// Generate the headers for an AlamoFire HTTP request to the API
    /// - Parameter token: string of the user's firebase authorization token
    /// - Returns: HTTP headers
    private func generateHTTPHeader(token:String) -> HTTPHeaders {
        let headerVal = "Bearer " + (token)
        let header = HTTPHeader(name: "Authorization", value: headerVal)
        let headers = HTTPHeaders(arrayLiteral: header)
        return headers
    }
    
    /// Helper function to updateUserPoints
    ///
    /// - Parameters:
    ///   - log: Log to be saved
    ///   - userRef: DocumentReference for firebase user
    ///   - updatePointValue: Bool for if the point is being update. Set this to false if this log has not been previously approved or rejected
    ///   - onDone: Closure to run when the function is finished or errors
    private func updateUserPoints(log:PointLog, residentID:String, updatePointValue:Bool, onDone:@escaping (_ err:Error?)->Void) {
        //Start Firebase Transaction - Used to prevent concurrency issues when updating a value
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            //Get the old user document
            let docRef = self.db.collection(self.USERS).document(residentID)
			let userDocument: DocumentSnapshot
			do {
				try userDocument = transaction.getDocument(docRef)
			} catch let fetchError as NSError {
				errorPointer?.pointee = fetchError
				return nil
			}
			//Get the value of the old points total for the user
			guard let oldTotal = userDocument.data()!["TotalPoints"] as? Int else {
				let error = NSError(
					domain: "AppErrorDomain",
					code: -1,
					userInfo: [
						NSLocalizedDescriptionKey: "Unable to retrieve TotalPoints from snapshot \(String(describing: userDocument))"
					]
				)
				errorPointer?.pointee = error
				return nil
			}
			//Update the value
			var newTotal = oldTotal
			if(updatePointValue){
				if(log.wasRejected()){
					newTotal -= log.type.pointValue // if log is being updated and is rejected, subtract points
				}
				else{
					newTotal += log.type.pointValue // if log is being updated and it is approved, add points
				}
			}
			else{
				newTotal += log.type.pointValue // If this is the first time being updated, add points
			}
			//Complete transaction update
			transaction.updateData(["TotalPoints": newTotal], forDocument: docRef)
			return nil
        })
        { (object, error) in
            //handle errors
            if let error = error {
                print("Transaction failed: \(error)")
                onDone(error)
            } else {
                print("Transaction successfully committed!")
                onDone(nil)
            }
        }
    }
    
    /// Helper function that contains the code that will actually update the House's points
    ///
    /// - Parameters:
    ///   - log: PointLog that is being handled/Updated
    ///   - houseRef: DocumentReference that points to house in Firebase
    ///   - updatePointValue: Bool if the pointlog is being updated after already being approved/rejected
    ///   - onDone: Closure to handle what to do when the function is finished or if there was an error
    private func updateHousePoints(log:PointLog, houseRef:DocumentReference, updatePointValue:Bool, onDone:@escaping (_ err:Error?)->Void)
    {
        //Transaction allows multiple firebase calls to occur without fear of concurrency issues
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            //Get the House Document from firebase
            let houseDocument: DocumentSnapshot
            do {
                try houseDocument = transaction.getDocument(houseRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            //Get the Total Points number from the object
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
            
            //Update a local value with the correct point value
            var newTotal = oldTotal
            if(updatePointValue){ //If log was already approved/rejected and the status has been changed
                if(log.wasRejected()){
                    newTotal -= log.type.pointValue //If log was approved but is now rejected, remove points
                }
                else{
                    newTotal += log.type.pointValue // If log was rejected but is now approved, add points
                }
            }
            else{
                newTotal += log.type.pointValue //If log has not been handled yet, then add the points.
                //NOTE: because the log had to be either updating or approved to call this function,
                //      we do not need to check for the log not being approved
            }
            
            //Update Firebase with new value
            transaction.updateData(["TotalPoints": newTotal], forDocument: houseRef)
            return nil
        }){ (object, error) in
            //Error Handling
            if let error = error {
                print("Transaction failed: \(error)")
                onDone(error)
            } else {
                print("Transaction successfully committed!")
                onDone(nil)
            }
        }
    }
    
    /// Private helper function that will handle the updating of the house points for House and User in firebase
    /// Note this will need to be changed when we switch to API and MySQL database
    ///
    /// - Parameters:
    ///   - log: Point Log that contains points to be given to House and Resident
    ///   - residentID: String of the user's id
    ///   - houseRef: Reference to the house that will be given the points
    ///   - isRECGrantingAward: Boolean (defaults to false) true if REC is giving award to entire house
    ///   - updatePointValue: Boolean if this point is being updated. Make this true if log was already approved or disapproved, and this is an update to its status that requires its point value be changed.
    ///   - onDone: Closure function to be called on completion. Err is nil if no errors are thrown.
	private func updateHouseAndUserPoints(log:PointLog, residentID: String, houseRef:DocumentReference, isRECGrantingAward:Bool = false, updatePointValue:Bool, onDone:@escaping (_ err:Error?)->Void)
    {
        updateHousePoints(log: log, houseRef: houseRef, updatePointValue: updatePointValue , onDone: {(err:Error?)in
            if(err != nil){
                onDone(err)
            }
            //If REC is giving award to House, dont give the points to a specific user
            else if(!isRECGrantingAward){
				self.updateUserPoints(log: log, residentID: residentID, updatePointValue: updatePointValue, onDone: {(errDeep:Error?) in
                    onDone(errDeep)
                })
            }
            else{
                onDone(nil)
            }
        })
    }
    
    func createQRCode(singleUse:Bool, pointID:Int, description:String, isEnabled:Bool, onDone:@escaping ( _ code:[String : Any]?, _ err:Error?) -> Void) {
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                onDone(nil, err)
                let banner = NotificationBanner(title: "Failure", subtitle: "Could not create QR code.", style: .danger)
                banner.duration = 2
                banner.show()
            } else {
                let headerVal = "Bearer " + (token ?? "")
                let header = HTTPHeader(name: "Authorization", value: headerVal)
                let headers = HTTPHeaders(arrayLiteral: header)
                let url = URL(string: self.CREATE_QR_LINK)!
                let params = ["single_use":singleUse.description, "point_id":pointID, "description":description, "is_enabled":isEnabled.description] as [String : Any]
                AF.request(url, method: .post, parameters: params, headers: headers).validate().responseJSON { response in
                    if let result = response.value as? [String : Any] {
                        onDone(result, nil)
                    }
                }
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
                    let archived = document.data()["Archived"] as! Bool
                    let claimedCount = document.data()["ClaimedCount"] as! Int
                    let creatorID = document.data()["CreatorID"] as! String
                    let descr = document.data()["Description"] as! String
                    let dyLink = document.data()["DynamicLink"] as! String
                    let enabled = document.data()["Enabled"] as! Bool
                    let pointID = document.data()["PointID"] as! Int
                    let pointDesc = document.data()["PointTypeDescription"] as! String
                    let pointName = document.data()["PointTypeName"] as! String
                    let pointVal = document.data()["PointTypeValue"] as! Int
                    let single = document.data()["SingleUse"] as! Bool
                    let link = Link(id: id, dynamicLink: dyLink, description: descr, singleUse: single, pointTypeID: pointID, pointTypeName: pointName, pointTypeDescription: pointDesc, pointTypeValue:pointVal, creatorID: creatorID, enabled:enabled, archived:archived, claimedCount: claimedCount)
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
    
    func getAllPointLogsForHouse(house:String, onDone:@escaping (([PointLog]) -> Void)){
        let docRef = db.collection(self.HOUSE).document(house).collection(self.POINTS)
        
        docRef.getDocuments()
            { (querySnapshot, error) in
                if (error != nil) {
                    print("Error getting documents: \(String(describing: error))")
                    return
                }
                var pointLogs = [PointLog]()
                for document in querySnapshot!.documents {
                    let floorID = document.data()["FloorID"] as! String
                    let id = document.documentID
                    let description = document.data()["Description"] as! String
                    let idType = (document.data()["PointTypeID"] as! Int)
					let dateOccurred = document.data()["DateOccurred"] as! Timestamp
					var firstName = document.data()["ResidentFirstName"] as! String
					let lastName = document.data()["ResidentLastName"] as! String
                    if(floorID == "Shreve"){
                        firstName = "(Shreve) " + firstName
                    }
					
					let residentId = User.get(.id) as! String
                    let pointType = DataManager.sharedManager.getPointType(value: abs(idType))
                    let pointLog = PointLog(pointDescription: description, firstName: firstName, lastName: lastName, type: pointType, floorID: floorID, residentId: residentId, dateOccurred: dateOccurred)
                    pointLog.logID = id
                    pointLogs.append(pointLog)
                }
                onDone(pointLogs)
        }
    }
	
	func getAllPointLogsForUser(residentID:String, house:String, onDone:@escaping (([PointLog]) -> Void)){
		let docRef = db.collection(self.HOUSE).document(house).collection(self.POINTS)
		
		docRef.getDocuments()
			{ (querySnapshot, error) in
				if (error != nil) {
					print("Error getting documents: \(String(describing: error))")
					return
				}
				var pointLogs = [PointLog]()
				for document in querySnapshot!.documents {
					let ID = document.data()["ResidentId"]
					if (ID != nil) {
						let resID = ID as! String
						if (resID == residentID) {
							let floorID = document.data()["FloorID"] as! String
							let id = document.documentID
							let description = document.data()["Description"] as! String
							let idType = (document.data()["PointTypeID"] as! Int)
							var firstName = document.data()["ResidentFirstName"] as! String
							let lastName = document.data()["ResidentLastName"] as! String
                            let dateSubmitted = document.data()["DateSubmitted"] as! Timestamp
                            let dateOccurred = document.data()["DateOccurred"] as! Timestamp
							if(floorID == "Shreve"){
								firstName = "(Shreve) " + firstName
							}
							let residentId = document.data()["ResidentId"] as! String
							let pointType = DataManager.sharedManager.getPointType(value: abs(idType))
							let pointLog = PointLog(pointDescription: description, firstName: firstName, lastName: lastName, type: pointType, floorID: floorID, residentId: residentId)
                            pointLog.dateSubmitted = dateSubmitted
                            pointLog.dateOccurred = dateOccurred
							pointLog.logID = id
							if (idType >= 0) {
								pointLog.wasHandled = true
							}
							pointLogs.append(pointLog)
						}
					}
				}
				onDone(pointLogs)
		}
	}
	
	func getMessagesForUser(onDone: @escaping ([PointLog])-> Void){
		let permissionLevel = PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)!
		
		let house = User.get(.house) as! String
		
        let resID = User.get(.id) as! String
        var path: Query?
        if (permissionLevel == .resident) {
            path = db.collection(self.HOUSE).document(house).collection(self.POINTS).whereField("ResidentId", isEqualTo: resID).whereField("ResidentNotifications", isGreaterThan: 0)
        }
        else if (permissionLevel == .rhp) {
            path = db.collection(self.HOUSE).document(house).collection(self.POINTS).whereField("RHPNotifications", isGreaterThan: 0)
        }
        if (path != nil) {
            path!.getDocuments { (querySnapshot, err) in
                if (err != nil) {
                    print("Error getting documents: \(String(describing: err))")
                    return
                }
                var pointLogs = [PointLog]()
                for document in querySnapshot!.documents {
                    let pointLog = PointLog.init(id: document.documentID, document: document.data())
                    pointLogs.append(pointLog)
                }
                onDone(pointLogs)
            }
        }
        // This should never be reached
        onDone([])
		
	}

    func addPointType(pointType:PointType, onDone:@escaping (_ err:Error?)-> Void){
        let highestId = DataManager.sharedManager.getPoints()!.count + 1 // This has the potential for a race condition but oh well
        //Adding a point with a specific Document ID
        let ref = self.db.collection("PointTypes").document(highestId.description)
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                onDone(NSError(domain: "Document Exists", code: 1, userInfo: nil))
            } else {
                ref.setData([
                    "Name" : pointType.pointName,
                    "Description" : pointType.pointDescription,
                    "PermissionLevel" : pointType.permissionLevel.rawValue,
                    "ResidentsCanSubmit"    : pointType.residentCanSubmit,
                    "Value"  : pointType.pointValue,
                    "Enabled" : pointType.isEnabled
                ]){ err in
                    onDone(err)
                }
            }
        }
    }
    
    func updatePointType(pointType:PointType, onDone:@escaping (_ err:Error?)-> Void){
        //Adding a point with a specific Document ID
        let ref = self.db.collection("PointTypes").document(pointType.pointID.description)
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                ref.setData([
                    "Name" : pointType.pointName,
                    "Description" : pointType.pointDescription,
                    "PermissionLevel" : pointType.permissionLevel.rawValue,
                    "ResidentsCanSubmit"    : pointType.residentCanSubmit,
                    "Value"  : pointType.pointValue,
                    "Enabled" : pointType.isEnabled
                ]){ err in
                    onDone(err)
                }
            } else {
                onDone(NSError(domain: "Document does not exist", code: 1, userInfo: nil))
            }
        }
    }
    
    func getTopScorersForHouse(house:String, onDone:@escaping ([UserModel]) -> Void){
        let collectionRef = db.collection(self.USERS)
        collectionRef.whereField("House", isEqualTo: house).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents For House: \(String(describing: error))")
                return
            }
            var users = [UserModel]()
            for document in querySnapshot!.documents{
                let permissionLevel = document.data()["Permission Level"] as! Int
                // Only consider residents, privileged residents, and rhps
                if (permissionLevel == PointType.PermissionLevel.resident.rawValue
                        || permissionLevel == PointType.PermissionLevel.priv.rawValue
                        || permissionLevel == PointType.PermissionLevel.rhp.rawValue) {
                    let firstName = document.data()["FirstName"] as! String
                    let lastName = document.data()["LastName"] as! String
                    let name = firstName + " " + lastName
                    let points = document.data()["TotalPoints"] as! Int
                    let model = UserModel(name: name, points: points)
                    if(users.count < 5){
                        users.append(model)
                        users.sort(by: { (um, um2) -> Bool in
                            return um.totalPoints > um2.totalPoints
                        })
                    }
                    else{
                        for i in 0..<5{
                            if(users[i].totalPoints < model.totalPoints){
                                users.insert(model, at: i)
                                users.remove(at: 5)
                                break;
                            }
                        }
                    }
                }
                
            }
            onDone(users)
        }
    }
    
    enum RetrievalError: Error {
        case unableToParseResponse
    }
    
    func getHouseRank(residentID: String, house: String, onDone:@escaping (Int?, Int?, Error?)->Void){
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                onDone(nil, nil, err)
            }
            let headerVal = "Bearer " + (token ?? "")
            let header = HTTPHeader(name: "Authorization", value: headerVal)
            let headers = HTTPHeaders(arrayLiteral: header)
            let url = URL(string: self.RANK_URL)!
            AF.request(url, method: .get, parameters: nil, headers: headers).validate().responseJSON { response in
                if let result = response.value as? [String : Int] {
                    onDone(result["houseRank"], result["semesterRank"], nil)
                }
            }
            onDone(nil, nil, RetrievalError.unableToParseResponse)
        }
    }
    
    func deleteReward(reward:Reward, onDone:@escaping (_ err:Error?) -> Void) {
        
        // todo: when setting url for AF, add the reward ID to the end of the request
        var ref: DocumentReference? = nil
        ref = self.db.collection("Rewards").document(reward.id)
        ref!.delete { (error) in
            onDone(error)
        }
    }
    
    func deletePictureWithFilename(filename:String,onDone:@escaping ( _ err:Error?) ->Void ) {
        let pathReference = storage.reference(withPath: filename)
        pathReference.delete { (error) in
            onDone(error)
        }
    }
    
    func uploadImageWithFilename(filename:String,img:UIImage, onDone:@escaping (_ downloadURL: String, _ err:Error?)->Void){
        let ref = self.storage.reference().child(filename)
        let data = img.pngData()!
        print("DATA SIZE: ",data.count)
        if(data.count > 20 * 1024 * 1024){
            onDone("", NSError(domain: "Image is too large", code: 1, userInfo: nil))
        }
        else{
            ref.putData(data, metadata: nil) { (storage, error) in
                ref.downloadURL { url, err in
                    onDone(url!.absoluteString, err)
                }
            }
        }
        
    }
    
    func createReward(reward:Reward, onDone:@escaping (_ err:Error?)->Void){
        
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                onDone(err)
            }
            let headerVal = "Bearer " + (token ?? "")
            let header = HTTPHeader(name: "Authorization", value: headerVal)
            let headers = HTTPHeaders(arrayLiteral: header)
            let url = URL(string: self.UPDATE_REWARD_URL)!
            let parameters : [String : Any] = ["id":reward.id, "fileName":reward.fileName, "downloadURL":reward.downloadURL, "name":reward.rewardName, "requiredPPR":reward.requiredPPR]
            AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                if let result = response.value as? [String : Int] {
                    onDone(nil)
                }
            }
        }
        
        
//        var ref: DocumentReference? = nil
//        ref = self.db.collection("Rewards").document(reward.rewardName)
//        ref!.getDocument { (document, error) in
//            if let document = document, document.exists {
//                onDone(NSError(domain: "Document Exists", code: 1, userInfo: nil))
//            } else {
//                ref!.setData([
//                    "Name" : reward.rewardName,
//                    "FileName" : reward.fileName,
//                    "RequiredPPR" : reward.requiredPPR
//                ]){ err in
//                    onDone(err)
//                }
//            }
//        }
    }
    
    func updateReward(reward:Reward, onDone:@escaping (_ err:Error?)->Void){
        
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                onDone(err)
            }
            let headerVal = "Bearer " + (token ?? "")
            let header = HTTPHeader(name: "Authorization", value: headerVal)
            let headers = HTTPHeaders(arrayLiteral: header)
            let url = URL(string: self.UPDATE_REWARD_URL)!
            let parameters : [String : Any] = ["id":reward.id, "fileName":reward.fileName, "downloadURL":reward.downloadURL, "name":reward.rewardName, "requiredPPR":reward.requiredPPR]
            AF.request(url, method: .put, parameters: parameters, headers: headers).validate().responseJSON { response in
                if let result = response.value as? [String : Int] {
                    onDone(nil)
                }
            }
        }
        
    }
    
    // Event Functions
    func getEvents(onDone:@escaping ([Event], Error?) ->Void) {
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
         var events: [Event] = [Event]()
         if let err = err {
            print("Error in retrieving auth token in getEvents()")
            onDone(events, err)
         }
        let headers = self.generateHTTPHeader(token: token!)
         let url = URL(string: self.GET_EVENT_URL)!
         AF.request(url, method: .get, parameters: nil, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let results = response.value as? [String : Any] {
                    // Parse Event Supplied
                    let eventsReturned = results["events"] as! [[String:Any]]
                    
                    for result in eventsReturned {
                       
                       let name = result["name"] as! String
                       let location = result["location"] as! String
                       let pointTypeId = result["pointTypeId"] as! String
                       let floorIds = result["floorIds"] as! [String]
                       let details = result["details"] as! String
                       let isPublicEvent = result["isPublicEvent"] as! Bool
                       let startDate = result["startDate"] as! String
                       let endDate = result["endDate"] as! String
                       let creatorId = result["creatorId"] as! String
                       let host = result["host"] as! String
                       let floorColors = result["floorColors"] as! [String]
                       let id = result["id"] as! String
                       let virtualLink = result["virtualLink"] as? String ?? ""
                    

                       let event = Event(name: name, location: location, pointTypeId: pointTypeId, floors: floorIds, details: details, isPublicEvent: isPublicEvent, startDateTime: startDate, endDateTime: endDate, creatorID: creatorId, host: host, floorColors: floorColors, id: id, virtualLink: virtualLink)
                       
                       events.append(event)
                   }
                   
                   onDone(events, nil)
                }
            case .failure:
                print(response)
                print("Failed Events Attempt")
                onDone(events, RetrievalError.unableToParseResponse)
             }
         }
         //onDone(events, RetrievalError.unableToParseResponse)
        }
    }
    
    func addEvent(event: Event, onDone:@escaping (_ err:Error?)->Void) {
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            //var events: [Event?]?
            if let err = err {
                print("Error getting authorization token")
                //events = nil
                onDone(err)
            }
            let headerVal = "Bearer " + (token ?? "")
            let header = HTTPHeader(name: "Authorization", value: headerVal)
            let headers = HTTPHeaders(arrayLiteral: header)
            let url = URL(string: self.ADD_EVENT_URL)!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startDateString = dateFormatter.string(from: event.startDate)
            let endDateString = dateFormatter.string(from: event.endDate)
            dateFormatter.dateFormat = "HH:mm:ss"
            let startTimeString = dateFormatter.string(from: event.startTime)
            let endTimeString = dateFormatter.string(from: event.endTime)
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let startDateTime = dateFormatter.date(from: startDateString + " " + startTimeString)
            let endDateTime = dateFormatter.date(from: endDateString + " " + endTimeString)
            
            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
            dateFormatter.locale = enUSPosixLocale
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            let startDateTimeString = dateFormatter.string(from: startDateTime!)
            let endDateTimeString = dateFormatter.string(from: endDateTime!)
           
            let parameters: [String: Any] = ["name":event.name, "details":event.details, "startDate":startDateTimeString, "endDate":endDateTimeString, "location":event.location, "pointTypeId":event.pointType.pointID, "floorIds":event.floors, "isPublicEvent":event.isPublicEvent, "isAllFloors":event.isAllFloors, "host":event.host, "virtualLink":event.virtualLink]
            
            print(parameters)
            
            AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                if let result = response.value as? [String : Any] {
                    print("Add Event Result:")
                    print(result)
                    onDone(nil)
                } else {
                    print("Error description")
                    print(response.error!.errorDescription!)
                    // Parse out error type to get code that made it fail.
                    onDone(RetrievalError.unableToParseResponse)
                }
            }
        }
    }
    
    func editEvent(event: Event, origID: String, onDone:@escaping (_ err:Error?, _ event: Event?)->Void) {
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                print("Error in editEvent()")
                onDone(err, nil)
            }
            let headerVal = "Bearer " + (token ?? "")
            let header = HTTPHeader(name: "Authorization", value: headerVal)
            let headers = HTTPHeaders(arrayLiteral: header)
            let url = URL(string: self.ADD_EVENT_URL)!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startDateString = dateFormatter.string(from: event.startDate)
            let endDateString = dateFormatter.string(from: event.endDate)
            dateFormatter.dateFormat = "HH:mm:ss"
            let startTimeString = dateFormatter.string(from: event.startTime)
            let endTimeString = dateFormatter.string(from: event.endTime)
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let startDateTime = dateFormatter.date(from: startDateString + " " + startTimeString)
            let endDateTime = dateFormatter.date(from: endDateString + " " + endTimeString)
            
            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
            dateFormatter.locale = enUSPosixLocale
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            let startDateTimeString = dateFormatter.string(from: startDateTime!)
            let endDateTimeString = dateFormatter.string(from: endDateTime!)
            
            let parameters: [String: Any] = ["id":origID, "name":event.name, "details":event.details, "startDate":startDateTimeString, "endDate":endDateTimeString, "location":event.location, "pointTypeId":event.pointType.pointID, "floorIds":event.floors, "isPublicEvent":event.isPublicEvent, "isAllFloors":event.isAllFloors, "host":event.host, "virtualLink":event.virtualLink]
            
            print("Parameters of new event")
            print(parameters)
            
            AF.request(url, method: .put, parameters: parameters, headers: headers).validate().responseJSON { response in
                if let result = response.value as? [String : Any] {
                    print("Edit Event Result:")
                    print(result)
                    
                    let name = result["name"] as! String
                    let location = result["location"] as! String
                    let pointTypeId = result["pointTypeId"] as! String
                    let floorIds = result["floorIds"] as! [String]
                    let details = result["details"] as! String
                    let isPublicEvent = result["isPublicEvent"] as! Bool
                    let startDate = result["startDate"] as! String
                    let endDate = result["endDate"] as! String
                    let creatorId = result["creatorId"] as! String
                    let host = result["host"] as! String
                    let floorColors = result["floorColors"] as! [String]
                    let id = result["id"] as! String
                    let virtualLink = result["virtualLink"] as? String ?? ""

                    let event = Event(name: name, location: location, pointTypeId: pointTypeId, floors: floorIds, details: details, isPublicEvent: isPublicEvent, startDateTime: startDate, endDateTime: endDate, creatorID: creatorId, host: host, floorColors: floorColors, id: id, virtualLink: virtualLink)
                    
                    onDone(nil, event)
                } else {
                    print(response.error!.errorDescription!)
                    onDone(RetrievalError.unableToParseResponse, nil)
                }
            }
            //onDone(RetrievalError.unableToParseResponse, nil)
        }
    }
    
    func deleteEvent(origID: String, onDone:@escaping (_ err:Error?)->Void) {
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
            if let err = err {
                print("Error in deleteEvent()")
                onDone(err)
            }
            let headerVal = "Bearer " + (token ?? "")
            let header = HTTPHeader(name: "Authorization", value: headerVal)
            let headers = HTTPHeaders(arrayLiteral: header)
            let url = URL(string: self.ADD_EVENT_URL + origID)!
            
            let parameters: [String: Any] = ["eventId":origID]
            
            print(JSONSerialization.isValidJSONObject(parameters))
            print(parameters)
            
            AF.request(url, method: .delete, parameters: parameters, headers: headers).validate().responseJSON { response in
                if let result = response.value as? [String : Any] {
                    print("Delete Event Result:")
                    print(result)
                    onDone(nil)
                } else {
                    print(response.error!.errorDescription!)
                    onDone(RetrievalError.unableToParseResponse)
                }
            }
            //onDone(RetrievalError.unableToParseResponse)
        }
    }
     
    func getEventsCreated(onDone:@escaping ([Event], Error?) ->Void) {
        DataManager.sharedManager.getAuthorizationToken { (token, err) in
         var events: [Event] = [Event]()
         if let err = err {
            print("Error in getEventsCreated()")
            onDone(events, err)
         }
         let headerVal = "Bearer " + (token ?? "")
         let header = HTTPHeader(name: "Authorization", value: headerVal)
         let headers = HTTPHeaders(arrayLiteral: header)
         let url = URL(string: self.ADD_EVENT_URL)!
         AF.request(url, method: .get, parameters: nil, headers: headers).validate().responseJSON { response in
            if let results = response.value as? [String : Any] {
               // Parse Event Supplied
               let eventsReturned = results["events"] as! [[String:Any]]
               
               for result in eventsReturned {
                   
                   let name = result["name"] as! String
                   let location = result["location"] as! String
                   let pointTypeId = result["pointTypeId"] as! String
                   let floorIds = result["floorIds"] as! [String]
                   let details = result["details"] as! String
                   let isPublicEvent = result["isPublicEvent"] as! Bool
                   let startDate = result["startDate"] as! String
                   let endDate = result["endDate"] as! String
                   let creatorId = result["creatorId"] as! String
                   let host = result["host"] as! String
                   let floorColors = result["floorColors"] as! [String]
                   let id = result["id"] as! String
                   let virtualLink = result["virtualLink"] as? String ?? ""

                   let event = Event(name: name, location: location, pointTypeId: pointTypeId, floors: floorIds, details: details, isPublicEvent: isPublicEvent, startDateTime: startDate, endDateTime: endDate, creatorID: creatorId, host: host, floorColors: floorColors, id: id, virtualLink: virtualLink)
                
                   events.append(event)
               }
               
               onDone(events, nil)
            } else {
               print(response)
               print("Failed Events Created Attempt")
                onDone(events, RetrievalError.unableToParseResponse)
            }
         }
         //onDone(events, RetrievalError.unableToParseResponse)
        }
    }
    
	
	/// Retrieves the system preferences for the app
	///
	/// - Parameter onDone: returns the system preferences that were retrieved
	func getSystemPreferences(onDone: @escaping (_ sysPref:SystemPreferences?)->Void) {
		let ref: DocumentReference? = self.db.collection("SystemPreferences").document("Preferences")
		ref?.getDocument { (document, error) in
			if let document = document, document.exists {
                let isHouseEnabled = document.data()!["isHouseEnabled"] as! Bool
                let houseEnabledMessage = document.data()!["houseEnabledMessage"] as! String
                let showRewards = document.data()!["ShowRewards"] as! Bool
				let iosVersion = document.data()!["iOS_Version"] as! String
                let suggestedPointIDs = document.data()!["suggestedPointIDs"] as! String
                let competitionHiddenMessage = document.data()!["competitionHiddenMessage"] as! String
                let isCompetitionVisible = document.data()!["isCompetitionVisible"] as! Bool
                let floorIds = document.data()!["floorIds"] as! [String]
                let systemPreferences = SystemPreferences(isHouseEnabled: isHouseEnabled, houseEnabledMessage: houseEnabledMessage, showRewards: showRewards, iosVersion: iosVersion, suggestedPointIDs: suggestedPointIDs, isCompetitionVisible: isCompetitionVisible, competitionHiddenMessage: competitionHiddenMessage, floorIds: floorIds)
				onDone(systemPreferences)
			} else {
				print("Error: Unabled to retrieve SystemPreferences information")
				onDone(nil)
			}
		}
	}
	
	/// Update System Preferences in Firebase
	///
	/// - Parameters:
	///   - systemPreferences: The updated local system preferences
	///   - onDone: Closure to handle error
	func updateSystemPreferences(systemPreferences: SystemPreferences, withCompletion onDone:@escaping ( _ err:Error?) ->Void){
		db.collection("SystemPreferences").document("Preferences").updateData(systemPreferences.convertToDictionary()){err in
			onDone(err)
		}
	}
    
    func getAuthorizationToken(onDone: @escaping(_ token:String?, _ err:Error?)->Void) {
        Auth.auth().currentUser!.getIDTokenForcingRefresh(true, completion: onDone)
    }

}

