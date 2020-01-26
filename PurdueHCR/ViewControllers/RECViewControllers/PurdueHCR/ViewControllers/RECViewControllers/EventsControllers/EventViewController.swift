//
//  ViewController.swift
//  HCR_Calendar
//
//  Created by Brennan Doyle on 9/14/19.
//  Copyright © 2019 Brennan Doyle. All rights reserved.
//




import UIKit

var events: [Event] = [Event(name: "Snack and Chat", location: "Innovation Forum", points: 1, house: 1, description: "Eat snacks and chat with students and faculty", fullDate: "Sun, Sep 15 2019", time: "5:00 PM", ownerID: "1234567890")]

var makeSection: Bool = true

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var eventTableView: UITableView!
        
    let cellSpacing: CGFloat = 35
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventTableView.reloadData()

   //     eventTableView.tableHeaderView!.frame = CGRectMake(0,0,200,300)
        self.eventTableView.tableHeaderView = self.eventTableView.tableHeaderView
        
        eventTableView.rowHeight = 133
        eventTableView.sectionHeaderHeight = 2000
        eventTableView.estimatedSectionHeaderHeight = 2000

        
        events = Event.sortEvents(events: events)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        eventTableView.reloadData()
        events = Event.sortEvents(events: events)
    }
    
    

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //makeSection = true
        var header: String = ""
        if section == 0 {
            header = events[section].fullDate
        }
        else {
            if events[section].date == events[section - 1].date { //If same date as previous event, don't print date.
                makeSection = false
                print("should be false now")
                return nil
            }
            else {
                header = events[section].fullDate
            }
        }
        return header 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Event.numRowsInSection(section: section, events: events)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return Event.getNumUniqueDates(events: events)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell

        
        // Currently, due to the borderWidth/Color, shadow does not show up.
//        cell.layer.shadowColor = UIColor.lightGray.cgColor
//        cell.layer.shadowOpacity = 0.5
//        cell.layer.shadowOffset = CGSize.zero
//        cell.layer.shadowRadius = 12
        
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        //Creates vertical space between same-day events (no date in between them)
        cell.layer.borderWidth = 4
        cell.layer.borderColor = UIColor.white.cgColor
                
        let sectionIndex = Event.startingIndexForSection(section: indexPath.section, events: events)
        
        cell.eventName.text = events[sectionIndex + indexPath.row].name
                
        cell.eventDate.text = events[sectionIndex + indexPath.row].time
        
        
        cell.eventLocation.text = events[sectionIndex + indexPath.row].location
        if events[sectionIndex + indexPath.row].points == 1 {
            cell.eventPoints.text = "1 Point"
        } else {
            cell.eventPoints.text = "\(events[sectionIndex + indexPath.row].points) Points"
        }
        
        //Setting background color based on who the event is for (by house)
        let color = events[sectionIndex + indexPath.row].house
        if color == 1 { //All houses
            cell.backgroundColor = UIColor(red: 233/255, green: 188/255, blue: 74/255, alpha: 1.0)
        }
        else if color == 2 { //Silver, Update Floor
            cell.backgroundColor = UIColor(red: 88/255, green: 196/255, blue: 0/255, alpha: 1.0)

        }
        else if color == 3 { //Palladium, 3rd Floor
            cell.backgroundColor = UIColor.lightGray
        }
        else if color == 4 { //Platinum, 4th Floor
            cell.backgroundColor = UIColor(red: 0/255, green: 218/255, blue: 229/255, alpha: 1.0)
        }
        else if color == 5 { //Titanium, Update Floor
            cell.backgroundColor = UIColor(red: 141/255, green: 113/255, blue: 226/255, alpha: 1.0)

        }
        else if color == 6 { //Copper, Update Floor
            cell.backgroundColor = UIColor(red: 247/255, green: 148/255, blue: 0/255, alpha: 1.0)
        }
        cell.eventDescription.text = events[sectionIndex + indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 0, y: 0, width: 320, height: self.tableView(eventTableView, heightForHeaderInSection: section))
        myLabel.font = UIFont.boldSystemFont(ofSize: 26)
        myLabel.text = self.tableView(eventTableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.addSubview(myLabel)
        headerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        return headerView
    }
}



