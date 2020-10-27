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
    var startDate: Date
    var startTime: Date
    var endDate: Date
    var endTime: Date
    var location: String
    var points: Int
    var house: String
    var details: String
    var creatorID: String
    var host: String
    static let dateFormat = "E, MMM d yyyy"
    static let timeFormat = "h:mm a"
        
    init (name: String, location: String, points: Int, house: String, details: String, startDateTime: String, endDateTime: String, creatorID: String, host: String) {
        self.name = name;
        self.location = location
        self.points = points
        self.house = house
        self.details = details
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Event.dateFormat + " " + Event.timeFormat
        let fullStartDateTime = dateFormatter.date(from: startDateTime)!
        let fullEndDateTime = dateFormatter.date(from: endDateTime)!
        
        dateFormatter.dateFormat = Event.dateFormat
        let startDateString = dateFormatter.string(from: fullStartDateTime)
        let endDateString = dateFormatter.string(from: fullEndDateTime)
        self.startDate = dateFormatter.date(from: startDateString)!
        self.endDate = dateFormatter.date(from: endDateString)!
        
        dateFormatter.dateFormat = Event.timeFormat
        let startTimeString = dateFormatter.string(from: fullStartDateTime)
        let endTimeString = dateFormatter.string(from: fullEndDateTime)
        self.startTime = dateFormatter.date(from: startTimeString)!
        self.endTime = dateFormatter.date(from: endTimeString)!
        
        
        self.creatorID = creatorID
        self.host = host
    }
    
    static func startingIndexForSection(section: Int, events: [Event]) -> Int {
        var currentDate = events[0].startDate
        var ctr = 0
        var index = 0
        
        //Find Index of events at which the current section's date start
        for i in 0...events.count-1 {
            if ctr == section {
                break
            }
            if (events[i].startDate == currentDate) {
                continue;
            } else {
                ctr += 1
                currentDate = events[i].startDate
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
        let currentDate = events[index].startDate
        
        while true {
            if events[index + 1].startDate == currentDate { // Current date will still be correct for section from above loop
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
        var currentDate = events[0].startDate
        
        for i in 0...events.count-1 {
            if (events[i].startDate == currentDate) {
                continue;
            } else {
                ret += 1
                currentDate = events[i].startDate
            }
            
        }
        
        return ret
    }
    
    static func sortEvents(events: [Event]) -> [Event] {
        var done: Bool = false
        var change: Bool = false
        
        var ret = events
        
        if (events.count > 1) {
            while (!done) {
                change = false
                for i in 0...ret.count-2 {
                    if (ret[i].startDate > ret[i+1].startDate) {
                        change = true
                        let temp: Event = ret[i]
                        ret[i] = ret[i+1]
                        ret[i+1] = temp
                    }
                    if (ret[i].startDate == ret[i+1].startDate) {
                        let date0 = ret[i].startTime
                        let date1 = ret[i+1].startTime
                        if (date0 > date1) {
                            change = true
                            let temp: Event = ret[i]
                            ret[i] = ret[i+1]
                            ret[i+1] = temp
                        }
                    }
                }
                if change == false { done = true }
            }
        }
        return ret
    }
}
