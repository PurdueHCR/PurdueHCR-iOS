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
import Cely




class DataManager {
    
    public static let sharedManager = DataManager()
    private var firstRun = true
    private let fbh = FirebaseHelper()
	var pointTypes: [PointType] = [PointType]()
    private var _unconfirmedPointLogs: [PointLog]? = nil
	private var _confiredPointLogs: [PointLog]? = nil
    private var _houses: [House]? = nil
    private var _rewards: [Reward]? = nil
    private var _houseCodes: [HouseCode]? = nil
    private var _links: LinkList? = nil
	var systemPreferences : SystemPreferences?
    
    private init(){}
    

    
    func getPoints() ->[PointType]? {
        return self.pointTypes
    }
    
    
    func getPointType(value:Int)->PointType{
        for pt in self.pointTypes {
            if (pt.pointID == value){
                return pt
            }
        }
		return PointType(pv: 0, pn: "Unknown Point Type", pd: "This point type does not appear to be a valid point type.", rcs: false, pid: -1, permissionLevel: .rec, isEnabled:false) // The famous this should never happen comment
    }
    

    
    func createUser(onDone:@escaping (_ err:Error?)->Void ){
        fbh.createUser(onDone: onDone)
    }
    
    func getUserWhenLogginIn(id:String, onDone:@escaping (_ success:Bool) ->Void ){
        fbh.getUserWhenLogIn(id: id, onDone: onDone)
    }
    
    func refreshPointTypes(onDone:@escaping ([PointType])-> Void) {
        fbh.retrievePointTypes(onDone: {(pointTypes:[PointType]) in
            self.pointTypes = pointTypes
            onDone(self.pointTypes)
        })
    }
    
    func updatePointLogStatus(log:PointLog, approved:Bool, updating:Bool = false, onDone:@escaping (_ err:Error?)->Void){
        fbh.updatePointLogStatus(log: log, approved: approved, updating: updating, onDone:{[weak self] (_ err :Error?) in
            if(err != nil){
                print("Failed to confirm or deny point")
            }
            else{
				if (!updating) {
					if let index = self?._unconfirmedPointLogs!.firstIndex(of: log) {
						self?._unconfirmedPointLogs!.remove(at: index)
					}
				}
            }
            onDone(err)
        })
    }
    
    
    /// Add Point Log to the database
    ///
    /// - Parameters:
    ///   - log: PointLog that was submitted
    ///   - preApproved: Boolean that denotes whether the Log can skip RHP approval or not.
    ///   - onDone: Closure function the be called once the code hits an error or finish. err is nil if no errors are found.
    func writePoints(log:PointLog, preApproved:Bool = false, onDone:@escaping (_ err:Error?)->Void) {
        // take in a point log, write it to house then write the ref to the user
		fbh.addPointLog(log: log, preApproved: preApproved) { (err:Error?) in
			onDone(err)
		}
    }
    
    /// Add Award from REA/REC
    ///
    /// - Parameters:
    ///   - log: Log to be awarded to the hosue
    ///   - house: House that will be given the award
    ///   - onDone: Closure function the be called once the code hits an error or finish. err is nil if no errors are found.
    func awardPointsToHouseFromREC(log:PointLog, house:House, onDone:@escaping (_ err:Error?)->Void){
        // This is to seperate the awards from the real earnings from the individual floors in the house
        log.floorID = "Award"

        fbh.addPointLog(log: log, preApproved: true, house: house.houseID, isRECGrantingAward: true, onDone: onDone)
    }
	
	/// Retrieves the confirmed points
	///
	/// - Returns: The logs of the confirmed points.
	func getResolvedPointLogs()->[PointLog]?{
		return self._confiredPointLogs
	}
	
    func getUnconfirmedPointLogs()->[PointLog]?{
        return self._unconfirmedPointLogs
    }
	
    func refreshUser(onDone:@escaping (_ err:Error?)->Void){
        fbh.refreshUserInformation(onDone: onDone)
    }
	
	func refreshResolvedPointLogs(onDone: @escaping (_ pointLogs:[PointLog])->Void) {
		fbh.getResolvedPoints(onDone: {[weak self] (pointLogs:[PointLog]) in
			if let strongSelf = self {
				strongSelf._confiredPointLogs = pointLogs
			}
			onDone(pointLogs)
		})
	}
	
    func refreshUnconfirmedPointLogs(onDone:@escaping (_ pointLogs:[PointLog])->Void ){
        fbh.getUnconfirmedPoints(onDone: {[weak self] (pointLogs:[PointLog]) in
            if let strongSelf = self {
                strongSelf._unconfirmedPointLogs = pointLogs
            }
            onDone(pointLogs)
        })
    }
	
	func getMessagesForPointLog(pointLog: PointLog, onDone:@escaping (_ messageLogs:[MessageLog])->Void) {
		fbh.getMessagesForPointLog(pointLog: pointLog, onDone: {(messageLogs:[MessageLog]) in
			onDone(messageLogs.sorted(by: { $0.creationDate.dateValue() < $1.creationDate.dateValue() }))
		})
	}
	
	func addMessageToPointLog(message: String, messageType: MessageLog.MessageType, pointID: String) {
		fbh.addMessageToPontLog(message: message, messageType: messageType, pointID: pointID)
	}
	
    func refreshHouses(onDone:@escaping ( _ houses:[House]) ->Void){
        print("House refersh")
        fbh.refreshHouseInformation(onDone: { (houses:[House], codes:[HouseCode]) in
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
                if let data = image.pngData() {
                    try? data.write(to: imagePath)
                }
                onDone(image)
            })
        }
    }
    
	func initializeData(finished:@escaping (_ error: NSError?)->Void){
        print("INITIALIZE")
		let TOTALCOUNT = 5
        let counter = AppUtils.AtomicCounter(identifier: "initializeData")
		
		// Something about the way this guard is set up could probably be better...
		guard let _ = User.get(.firstName) else{
			guard let _ = User.get(.lastName) else {
				print("FAILED INIT")
				return
			}
			return
        }
        if let id = User.get(.id) as! String?{
            getUserWhenLogginIn(id: id, onDone: {(isLoggedIn:Bool) in
                if(!isLoggedIn){
                    finished(NSError(domain: "Unable to find account", code: 2, userInfo: nil))
                    return
                }
				self.refreshPointTypes(onDone: {(pointTypes:[PointType]) in
					counter.increment()
					if((User.get(.permissionLevel) as! Int) == 1){
						//Check if user is an RHP
						self.refreshUnconfirmedPointLogs(onDone:{(pointLogs:[PointLog]) in
							counter.increment()
							if(counter.value == TOTALCOUNT){
								finished(nil)
							}
						})
					}
					else{
						counter.increment()
						if(counter.value == TOTALCOUNT){
							finished(nil)
						}
					}
                })
                self.refreshHouses(onDone:{(houses:[House]) in
					if (houses.count == 0) {
						finished(NSError(domain: "Unable to load houses.", code: 1, userInfo: nil))
					} else {
						// Check if user is an REC, in which case you need to get the top scorers
						if((User.get(.permissionLevel) as! Int) == 2){
							self.getHouseScorers {
								counter.increment()
								if(counter.value == TOTALCOUNT){
									finished(nil)
								}
							}
						}
							//User is not REC, so they do not need house Scorers (yet)
						else{
							counter.increment()
							if(counter.value == TOTALCOUNT){
								finished(nil)
							}
						}
					}
                    
                })
                self.refreshRewards(onDone: {(rewards:[Reward]) in
					counter.increment()
					if(counter.value == TOTALCOUNT){
						finished(nil)
					}
                })
				self.refreshSystemPreferences(onDone: { (sysPref) in
					if (sysPref == nil) {
						finished(NSError(domain: "Unable to load system preferences.", code: 1, userInfo: nil))
					} else {
						counter.increment()
						if(counter.value == TOTALCOUNT) {
							finished(nil)
						}
					}
				})
            })
		}
		// If user is not found
		else {
			finished(NSError(domain: "Unable to find account", code: 2, userInfo: nil))
		}
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
        //Make sure that the user submitting a QR point is a Resident or an RHP
		
		let userLevel = User.get(.permissionLevel) as! Int
        if(userLevel != 0 && userLevel != 1){
            DispatchQueue.main.async {
                let banner = NotificationBanner(title: "Failure", subtitle: "Only residents can submit points.", style: .danger)
                banner.duration = 2
                banner.show()
            }
            return
        }
		
        fbh.findLinkWithID(id: id, onDone: {(linkOptional:Link?) in
            guard let link = linkOptional else {
                DispatchQueue.main.async {
                    let banner = NotificationBanner(title: "Failure", subtitle: "Could not submit points.", style: .danger)
                    banner.duration = 2
                    banner.show()
                }
                return
            }
            
            if(!link.enabled){
                DispatchQueue.main.async {
                    let banner = NotificationBanner(title: "Failure: Code is not enabled.", subtitle: "Talk to owner to change status.", style: .danger)
                    banner.duration = 2
                    banner.show()
                }
                return
            }
            let group = DispatchGroup()
            group.enter()
            
            DispatchQueue.global().async {
                while(!DataManager.sharedManager.isInitialized()){}
                group.leave()
            }
            group.notify(queue: .main) {
				if (!self.systemPreferences!.isHouseEnabled) {
					let banner = NotificationBanner(title: "Failure", subtitle: "House competition is inactive.", style: .danger)
					banner.duration = 2
					banner.show()
					return
				}
                
                let pointType = self.getPointType(value: link.pointTypeID)
				let firstName = User.get(.firstName) as! String
				let lastName = User.get(.lastName) as! String
                let floorID = User.get(.floorID) as! String
				let residentId = User.get(.id) as! String
                let log = PointLog(pointDescription: link.description, firstName: firstName, lastName: lastName, type: pointType, floorID: floorID, residentId: residentId)
                var documentID = ""
                //If the QR code is single use, set the id of the point log to residentID+LinkID. This prevents the same user from submitting it twice
                //If the QR Code is multiple use, do not set a documentID. Firestore will auto generate a random one.
                if(link.singleUse){
                    documentID = residentId + id
                }
				
                //NOTE: preApproved is now changed to SingleUseCodes || RHP
                self.fbh.addPointLog(log: log, documentID: documentID, preApproved: (link.singleUse || (User.get(.permissionLevel) as! Int) == 1) , onDone: {(err:Error?) in
                    if (err == nil){
						DispatchQueue.main.async {
                            let banner = NotificationBanner(title: "Success", subtitle: log.pointDescription, style: .success)
                            banner.duration = 2
                            print("Call this")
                            banner.show()
                        }
                        
                    }
                    else{
                        if(err!.localizedDescription == "The operation couldn’t be completed. (Document Exists error 1.)"){
                            DispatchQueue.main.async {
                                let banner = NotificationBanner(title: "Could not submit.", subtitle: "You have already scanned this code.", style: .danger)
                                banner.duration = 2
                                banner.show()
                            }
                        }
                        else if (err!.localizedDescription == "The operation couldn’t be completed. (Could not submit points because point type is disabled. error 1.)"){
                            DispatchQueue.main.async {
                                let banner = NotificationBanner(title: "Could not submit.", subtitle: "This type of point is disabled for now.", style: .danger)
                                banner.duration = 2
                                banner.show()
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                let banner = NotificationBanner(title: "Failure", subtitle: "Could not submit points due to server error.", style: .danger)
                                banner.duration = 2
                                banner.show()
                            }
                        }
                    }
                })
                
            }
            
        })
    }
    
    func getQRCodeFor(ownerID:String, withRefresh refresh:Bool, withCompletion onDone:@escaping ( _ links:LinkList?)->Void){
        if(refresh || self._links == nil){
            fbh.getQRCodeFor(ownerID: ownerID, withCompletion: {(links:[Link]?) in
                self._links = LinkList(links!)
                onDone(self._links)
            })
        }
        else{
            onDone(self._links)
        }
    }
    
    func setLinkActivation(link:Link, withCompletion onDone:@escaping ( _ err:Error?) ->Void){
        fbh.setLinkActivation(link: link, withCompletion: onDone)
    }
    
    func setLinkArchived(link:Link, withCompletion onDone:@escaping ( _ err:Error?) ->Void){
        fbh.setLinkArchived(link: link, withCompletion: onDone)
    }
    
    func getAllPointLogsForHouse(house:String, onDone:@escaping (([PointLog]) -> Void)){
        fbh.getAllPointLogsForHouse(house: house, onDone: onDone)
    }
	
	func getAllPointLogsForUser(residentID:String, house:String, onDone:@escaping (([PointLog]) -> Void)){
		fbh.getAllPointLogsForUser(residentID: residentID, house: house, onDone: onDone)
	}
	
	func getMessagesForUser(onDone: @escaping([PointLog]) -> Void) {
		fbh.getMessagesForUser(onDone: onDone)
	}
    
    func createPointType(pointType:PointType, onDone:@escaping ((_ err:Error?) ->Void)){
        fbh.addPointType(pointType: pointType, onDone: onDone)
    }
    
    func updatePointType(pointType:PointType, onDone:@escaping ((_ err:Error?) ->Void)){
        fbh.updatePointType(pointType: pointType, onDone: onDone)
    }
    
    func getTopScorersForHouse(house:House, onDone:@escaping () -> Void){
        fbh.getTopScorersForHouse(house: house.houseID, onDone: {
            models in
            house.topScoreUsers = models
            onDone()
        })
    }
    
    func getHouseScorers(onDone:@escaping ()->Void){
        //This must be called after the houses are initialized
        let counter = AppUtils.AtomicCounter.init(identifier: "TopScorersCounter")
        for house in self._houses!{
            getTopScorersForHouse(house: house) {
                counter.increment()
                if(counter.value == 5){
                    onDone()
                }
            }
        }
    }
    
    func createReward(reward:Reward, image:UIImage, onDone:@escaping(_ err:Error?) ->Void){
        fbh.uploadImageWithFilename(filename: reward.fileName, img: image) { (err) in
            if(err == nil){
                self.fbh.createReward(reward: reward, onDone: { (error) in
                    onDone(error)
                })
            }
            else{
                onDone(err)
            }
        }
    }
    
    func deleteReward(reward:Reward, onDone:@escaping (_ err:Error?) -> Void ){
        fbh.deletePictureWithFilename(filename: reward.fileName) { (error) in
            if(error == nil){
                self.fbh.deleteReward(reward: reward, onDone: { (err) in
                    onDone(err)
                })
            }
            else{
                onDone(error)
            }
        }
    }

    //Used for handling link to make sure all necessairy information is there
    func isInitialized() -> Bool {
        return getHouses() != nil && getPoints() != nil && Cely.currentLoginStatus() == .loggedIn && User.get(.id) != nil && User.get(.firstName) != nil && User.get(.lastName) != nil && User.get(.permissionLevel) != nil && systemPreferences != nil
		
    }
	
	func refreshSystemPreferences(onDone: @escaping (_ sysPref: SystemPreferences?)->Void) {
		fbh.getSystemPreferences { (sysPref) in
			if (sysPref == nil) {
				onDone(nil)
			} else {
				self.systemPreferences = sysPref
				onDone(sysPref)
			}
		}
	}
	
	/// Update System Preferences in Firebase
	///
	/// Saves the local system preferences to Firebase.
	/// Update the instance variables in the local system preferences before you call
	/// this method.
	///
	/// - Parameters:
	///   - onDone: Closure to handle error
	func updateSystemPreferences(withCompletion onDone:@escaping ( _ err:Error?) ->Void){
		fbh.updateSystemPreferences(systemPreferences: systemPreferences!, withCompletion: onDone)
	}
	
}


//class DataManager {
//
//    func retrievePointTypes() -> [PointGroup] {
//        return nil;
//    }
//}
