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
    var hour: Int //24 Hour, not 12AM,12PM
    var minute: Int
    var day: Int
    var month: Int
    var year: Int
    var fullDate: String
    var location: String
    var points: String
    var house: Int
    var description: String
    
    @IBOutlet weak var newEventDescription: UITextField!
    
    init (name: String, time: String, hour: Int, minute: Int, location: String, points: String, house: Int, description: String, day: Int, month: Int, year: Int, fullDate: String) {
        self.name = name;
        self.time = time;
        self.hour = hour
        self.minute = minute
        self.location = location
        self.points = points
        self.house = house
        self.description = description
        
        self.day = day
        self.month = month
        self.year = year
        self.fullDate = fullDate
    }
    
    func bubbleSwitch(event: Event) {
        self.name = event.name
        self.time = event.time
        self.location = event.location
        self.points = event.points
        self.house = event.house
        self.description = event.description
        self.day = event.day
        self.month = event.month
        self.year = event.year
        
    }
    
    
}
