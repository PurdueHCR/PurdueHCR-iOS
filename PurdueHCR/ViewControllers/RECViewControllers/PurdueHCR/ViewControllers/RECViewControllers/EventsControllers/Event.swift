//
//  Event.swift
//  HCR_Calendar
//
//  Created by Brennan Doyle on 9/14/19.
//  Copyright © 2019 Brennan Doyle. All rights reserved.
//

import UIKit

class Event {
    
    var name: String
    var time: String
    var fullDate: String
    var date: Date
    var location: String
    var points: Int
    var house: Int
    var description: String
    var ownerId: String
    
    @IBOutlet weak var newEventDescription: UITextField!
    
    init (name: String, location: String, points: Int, house: Int, description: String, fullDate: String, time: String, ownerID: String) {
        self.name = name;
        self.location = location
        self.points = points
        self.house = house
        self.description = description
        
        self.fullDate = fullDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d yyyy"
        self.date = dateFormatter.date(from: fullDate)!
        self.time = time
        
        self.ownerId = ownerID
    }
}
