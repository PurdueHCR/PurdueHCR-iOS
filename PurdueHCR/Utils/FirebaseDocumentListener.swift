//
//  FirebaseDocumentListener.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/25/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import FirebaseFirestore

public class FirebaseDocumentListener: FirebaseListener {
    
    init(docRef: DocumentReference) {
        super.init()
        FirebaseListener.listener = docRef.addSnapshotListener({ (docSnapshot, err) in
            self.handleCallbacks()
        })
    }
    
}
