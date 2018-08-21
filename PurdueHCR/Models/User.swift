//
//  User.swift
//  Purdue HCR
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//
//  This file contains the model and controller for handling the user information
//

import Foundation
import Cely



struct User: CelyUser {
    
    enum Property: CelyProperty {
        case name = "name"
        case email = "email"
        case id = "id"
        case house = "house"
        case permissionLevel = "pmlevel"
        case points = "points"
        case floorID = "flrCode"
        
        
        func securely() -> Bool {
            switch self {
            case .id:
                return true
            default:
                return false
            }
        }
        
        func persisted() -> Bool {
            switch self {
            case .name:
                return true
            case .house:
                return true
            case .permissionLevel:
                return true
            case .email:
                return true
            case .points:
                return true
            case .floorID:
                return true
            default:
                return false
            }
        }
        
        func save(_ value: Any) {
            Cely.save(value, forKey: rawValue, securely: securely(), persisted: persisted())
        }
        
        func get() -> Any? {
            return Cely.get(key: rawValue)
        }
    }
}

// MARK: - Save/Get User Properties

extension User {
    
    static func save(_ value: Any, as property: Property) {
        property.save( value)
    }
    
    static func save(_ data: [Property : Any]) {
        data.forEach { property, value in
            property.save(value)
        }
    }
    
    static func get(_ property: Property) -> Any? {
        return property.get()
    }
}
