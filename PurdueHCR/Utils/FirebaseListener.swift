//
//  FirebaseListener.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/25/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import FirebaseFirestore

public class FirebaseListener {
    
    typealias onUpdate = ()->Void
    private var callbackByStringMap : Dictionary = [String : onUpdate]()
    public static var listener: ListenerRegistration!
    
    init() {
        
    }
    
    func handleCallbacks() {
        for value in callbackByStringMap.values {
            value()
        }
    }
    
    func addCallback(key: String, value: @escaping(onUpdate)) {
        if (!callbackByStringMap.keys.contains(key)) {
            callbackByStringMap[key] = value
        }
        
    }
    
    func removeCallback(key: String) {
        if (callbackByStringMap.keys.contains(key)) {
            callbackByStringMap.removeValue(forKey: key)
        }
    }
    
    func killListener() {
        if (FirebaseListener.listener != nil) {
            FirebaseListener.listener.remove()
            callbackByStringMap.removeAll()
        }
    }
    
}
