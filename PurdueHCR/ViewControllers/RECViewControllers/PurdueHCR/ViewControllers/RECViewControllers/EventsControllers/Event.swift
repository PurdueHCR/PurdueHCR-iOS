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
    
    static func startingIndexForSection(section: Int, events: [Event]) -> Int {
        var currentDate = events[0].date
        var ctr = 0
        var index = 0
        
        //Find Index of events at which the current section's date start
        for i in 0...events.count-1 {
            if ctr == section {
                break
            }
            if (events[i].date == currentDate) {
                continue;
            } else {
                ctr += 1
                currentDate = events[i].date
                index = i
            }
        }
        
        return index
    }
    
    static func numRowsInSection(section: Int, events: [Event]) -> Int {
        var ret = 1
        
        var index = startingIndexForSection(section: section, events: events)
        
        //Loop throough until reaching a different date, incrementing ret.
        //Ret's value when breaking from loop is number of rows in each section.
        if (index + 1 == events.count) {
            return 1
        }
        let currentDate = events[index].date
        
        while true {
            if events[index + 1].date == currentDate { // Current date will still be correct for section from above loop
                ret += 1
                index += 1
            } else {
                return ret
            }
            if index + 1 == events.count {
                return ret
            }
        }
    }
    
    static func getNumUniqueDates(events: [Event]) -> Int {
        var ret = 1
        var currentDate = events[0].date
        
        for i in 0...events.count-1 {
            if (events[i].date == currentDate) {
                continue;
            } else {
                ret += 1
                currentDate = events[i].date
            }
            
        }
        
        return ret
    }
}
