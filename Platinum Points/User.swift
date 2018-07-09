//
//  User.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import Cely

struct User: CelyUser {
    
    enum Property: CelyProperty {
        case token = "token"
    }
    var permissionLevel:Int?
    var accountID:String?
    var name:String?
}
