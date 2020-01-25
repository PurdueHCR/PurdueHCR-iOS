//
//  FirebaseListenerUtil.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/25/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import FirebaseFirestore

public class FirebaseListenerUtil {
    
    private var userPointLogListener: FirebaseCollectionListener
    private var rhpNotificationListener: FirebaseCollectionListener
    private var pointTypeListener: FirebaseCollectionListener
    private var pointLogListener: FirestoreDocumentListener
    private var systemPreferenceListener: FirestoreDocumentListener
    private var userAccountListener: FirestoreDocumentListener
    
    func initializeListeners() {}
    
    init() {
        createPersistantListeners()
    }
    
    func createPersistantListeners() {
        createUserPointLogListener()
        createSystemPreferencesListener()
        createPointTypeListener()
        createUserAccountListener()
        if(PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int) == PointType.PermissionLevel.rhp) {
            //Create RHP only listeners
            createRHPNotificationListener();
        }
    }
    
    func removeCallbacks(key: String) {
        // FIXME: Some error checking here to determine which one to run
        userPointLogListener.removeCallback(key: key)
        rhpNotificationListener.removeCallback(key: key)
        pointTypeListener.removeCallback(key: key)
        pointLogListener.removeCallback(key: key)
        systemPreferenceListener.removeCallback(key: key)
        userAccountListener.removeCallback(key: key)
    }
    
    func resetFirebaseListeners() {
        killUserAccountListener()
        killPointLogListener()
        killRHPNotificationListener()
        killUserPointLogListener()
        killSystemPreferencesListener()
        killPointTypeListener()
        //FLUListener = nil
    }
    
    /*--------------------------User Account LISTENER-------------------------------------*/
    
    func createUserAccountListener() {
        if (userAccountListener != nil) {
            killUserAccountListener()
        }
        
        var docRef = DataManager.sharedManager.getUserRefFromUserID(id: User.get(.id) as! String)
        
        /*SnapshotInterface si = new SnapshotInterface() {
            @Override
            public void handleDocumentSnapshot(DocumentSnapshot documentSnapshot, Exception e) {
                if( e == null){
                    User user = (User) userAccountListener.getUpdatingObject();
                    user.setTotalPoints(((Long) documentSnapshot.getData().get(User.TOTAL_POINTS_KEY)).intValue());
                }
            }
        };*/
        //userAccountListener = new FirestoreDocumentListener(context,documentReference,si,user);

    }
    
    func getUserAccountListener()->FirebaseCollectionListener {
        return userAccountListener
    }
    
    func killUserAccountListener() {
        userAccountListener.killListener()
    }
    
    /*------------------------USER POINT LOG LISTENER---------------------------------------------*/
    
    func createUserPointLogListener() {
        DataManager.sharedManager.getAllPointLogsForUser(residentID: User.get(.id) as! String, house: User.get(.house) as! String) { ([PointLog]) in
            
        }
        /*
        SnapshotInterface si = new SnapshotInterface() {
            @Override
            public void handleQuerySnapshots(QuerySnapshot queryDocumentSnapshots, Exception e) {
                if( e == null){
                    List<PointLog> userLogs = new ArrayList<>();
                    for(DocumentSnapshot doc : queryDocumentSnapshots){
                        userLogs.add(new PointLog(doc.getId(),doc.getData(),context));
                    }
                    Collections.sort(userLogs);
                    cacheManager.setPersonalPointLogs(userLogs);
                }
            }
        };
        userPointLogListener = new FirebaseCollectionListener(context,userPointLogQuery,si);*/
    }
    
    func getUserPointLogListener()->FirebaseCollectionListener {
        return userPointLogListener
    }
    
    func killUserPointLogListener() {
        userPointLogListener.killListener()
    }
    
    /*------------------------RHP NOTIFICATION LISTENER-------------------------------------------*/
    
    func createRHPNotificationListener() {
        DataManager.sharedManager.getMessagesForUser { ([PointLog]) in
            
        }
        /*SnapshotInterface si = new SnapshotInterface() {
            @Override
            public void handleQuerySnapshots(QuerySnapshot queryDocumentSnapshots, Exception e) {
                if( e == null){
                    List<PointLog> notifiedLog = new ArrayList<>();
                    for(DocumentSnapshot doc : queryDocumentSnapshots){
                        notifiedLog.add(new PointLog(doc.getId(),doc.getData(),context));
                    }
                    Collections.sort(notifiedLog);
                    cacheManager.setRHPNotificationLogs(notifiedLog);
                    cacheManager.setNotificationCount(queryDocumentSnapshots.size());
                }

            }
        };
        rhpNotificationListener = new FirebaseCollectionListener(context,rhpNotificationQuery,si);*/
    }
    
    func getRHPNotificationListener()->FirebaseCollectionListener {
        return getRHPNotificationListener()
    }
    
    func killRHPNotificationListener() {
        rhpNotificationListener.killListener()
    }
    
    /*--------------------------INDIVIDUAL POINT LOG LISTENER-------------------------------------*/

    func createPointLogListener(pointLog: PointLog) {
        
        // Create method to get specific point log in datamanager...
        /*SnapshotInterface si = new SnapshotInterface() {
            @Override
            public void handleDocumentSnapshot(DocumentSnapshot documentSnapshot, Exception e) {
                    if( e == null){
                        PointLog relatedLog = (PointLog) pointLogListener.getUpdatingObject();
                        relatedLog.updateValues(new PointLog(documentSnapshot.getId(),documentSnapshot.getData(),context));
                    }
            }
        };
        pointLogListener = new FirestoreDocumentListener(context,documentReference,si,log);*/
        
    }
    
    func getPointLogListener()->FirebaseDocumentListener {
        return pointLogListener
    }
    
    func killPointLogListener() {
        pointLogListener.killListener()
    }

    /*---------------------------SYSTEM PREFERENCES LISTENER--------------------------------------*/
    
    func createSystemPreferencesListener() {
        // ADD DATABASE MANAGER METHOD TO GET SYSTEM PREFERENCES
        /*
         SnapshotInterface si = new SnapshotInterface() {
             @Override
             public void handleDocumentSnapshot(DocumentSnapshot documentSnapshot, Exception e) {
                 if(e == null){
                     SystemPreferences sp = (SystemPreferences) systemPreferenceListener.getUpdatingObject();
                     sp.updateValues(documentSnapshot.getData());
                 }
             }
         };
         systemPreferenceListener = new FirestoreDocumentListener(context,documentReference,si,systemPreferences);
         */
    }
    
    func getSystemPreferencesListener()->FirebaseDocumentListener {
        return systemPreferenceListener
    }
    
    func killSystemPreferencesListener() {
        systemPreferenceListener.killListener()
    }
    
    /*------------------------POINT TYPE LISTENER---------------------------------------------*/
    
    func createPointTypeListener() {
        // TODO: Get pointtypes from database manager
        /*SnapshotInterface si = new SnapshotInterface() {
            @Override
            public void handleQuerySnapshots(QuerySnapshot queryDocumentSnapshots, Exception e) {
                if( e == null){
                    List<PointType> types = new ArrayList<>();
                    for(DocumentSnapshot doc : queryDocumentSnapshots){
                        types.add(new PointType(Integer.parseInt(doc.getId()),doc.getData()));
                    }
                    Collections.sort(types);
                    cacheManager.setPointTypeList(types);
                }
            }
        };
        pointTypeListener = new FirebaseCollectionListener(context,pointTypeQuery,si);*/
    }
    
    func getPointTypeListener()->FirebaseCollectionListener {
        return pointTypeListener
    }
    
    func killPointTypeListener() {
        pointTypeListener.killListener()
    }

}
