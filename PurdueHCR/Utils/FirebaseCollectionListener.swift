//
//  FirebaseCollectionListener.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/25/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import FirebaseFirestore

public class FirebaseCollectionListener: FirebaseListener {
    
    init(q: Query?) {
        super.init()
        FirebaseListener.listener = q?.addSnapshotListener({ (queryDocumentSnapshots, err) in
            self.handleCallbacks()
        })
    }
    
}
