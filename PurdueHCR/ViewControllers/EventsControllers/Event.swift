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
    var details: String
    var startDate: Date
    var startTime: Date
    var endDate: Date
    var endTime: Date
    var location: String
    var pointType: PointType
    var floors: [String]
    var isPublicEvent: Bool
    var isAllFloors: Bool
    var host: String
    var creatorID: String
    var floorColors: [String]/*[RGB-Color] (Not sure what typing I will use for this field*/
    var eventID: String
    var virtualLink: String
    
    static let dateFormat: String = "E, MMM d yyyy"
    static let timeFormat: String = "h:mm a"
        
    init (name: String, location: String, pointType: PointType, floors: [String], details: String, isPublicEvent: Bool, isAllFloors: Bool, startDateTime: String, endDateTime: String, creatorID: String, host: String, virtualLink: String) {
        self.name = name;
        self.details = details
        self.location = location
        self.pointType = pointType
        self.floors = floors
        self.isPublicEvent = isPublicEvent
        self.isAllFloors = isAllFloors
        self.creatorID = creatorID
        self.host = host
        
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
        
        self.floorColors = [""]
        self.eventID = ""
        
        self.virtualLink = virtualLink
    }
    
    init (name: String, location: String, pointTypeId: String, floors: [String], details: String, isPublicEvent: Bool, startDateTime: String, endDateTime: String, creatorID: String, host: String, floorColors: [String], id: String, virtualLink: String) {
        self.name = name
        self.location = location
        
        self.pointType = DataManager.sharedManager.getPointType(value: Int(pointTypeId) ?? -1)
        
        self.floors = floors
        self.details = details
        self.isPublicEvent = isPublicEvent
        if (floors.count == DataManager.sharedManager.systemPreferences?.floorIds.count) {
            self.isAllFloors = true
        } else {
            self.isAllFloors = false
        }
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let startDateString = dateFormatter.string(from: event.startDate)
//        let endDateString = dateFormatter.string(from: event.endDate)
//        dateFormatter.dateFormat = "HH:mm:ss"
//        let startTimeString = dateFormatter.string(from: event.startTime)
//        let endTimeString = dateFormatter.string(from: event.endTime)
//        let startDateTimeString = startDateString + "T" + startTimeString + "+04:00"
//        let endDateTimeString = endDateString + "T" + endTimeString + "+04:00"
                
        let isoDateFormatter = ISO8601DateFormatter() //2021-01-20T13:00:00.000Z
        isoDateFormatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        let isoStartDateTime = isoDateFormatter.date(from: startDateTime)!
        let isoEndDateTime = isoDateFormatter.date(from: endDateTime)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let convertedStartDateString = dateFormatter.string(from: isoStartDateTime)
        let convertedEndDateString = dateFormatter.string(from: isoEndDateTime)
        self.startDate = dateFormatter.date(from: convertedStartDateString)!
        self.endDate = dateFormatter.date(from: convertedEndDateString)!
        dateFormatter.dateFormat = "HH:mm:ss"
        let convertedStartTimeString = dateFormatter.string(from: isoStartDateTime)
        let convertedEndTimeString = dateFormatter.string(from: isoEndDateTime)
        self.startTime = dateFormatter.date(from: convertedStartTimeString)!
        self.endTime = dateFormatter.date(from: convertedEndTimeString)!
            
        self.creatorID = creatorID
        self.host = host
        self.floorColors = floorColors
        self.eventID = id
        self.virtualLink = virtualLink
    }
    
    init () {
        self.name = ""
        self.details = ""
        self.startDate = Date()
        self.startTime = Date()
        self.endDate = Date()
        self.endTime = Date()
        self.location = ""
        self.pointType = PointType(pv: -1, pn: "", pd: "", rcs: false, pid: -1, permissionLevel: PointType.PermissionLevel.resident, isEnabled: false)
        self.floors = [""]
        self.isPublicEvent = false
        self.isAllFloors = false
        self.host = ""
        self.creatorID = ""
        self.floorColors = [""]/*[RGB-Color] (Not sure what typing I will use for this field*/
        self.eventID = ""
        self.virtualLink = ""
    }
    
    func setEventID(id: String) {
        self.eventID = id
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
        if (events.count == 0) {
            return 0
        }
        var ret = 1
        var currentDate = events[0].startDate
        
        for (_, elem) in events.enumerated() {
            if (elem.startDate == currentDate) {
                continue
            } else {
                ret += 1
                currentDate = elem.startDate
            }
            
        }
                
        return ret
    }
    
    static func sortEvents(events: [Event]) -> [Event] {
        var ret = events
        ret.sort(by: {$0.startDate < $1.startDate})
        return ret
    }
}
