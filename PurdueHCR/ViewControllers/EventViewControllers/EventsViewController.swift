//
//  ViewController.swift
//  HCR_Calendar
//
//  Created by Brennan Doyle on 9/14/19.
//  Copyright © 2019 Brennan Doyle. All rights reserved.
//




import UIKit

var events: [Event] = [Event(name: "Snack and Chat", time: "5:00 PM", hour: 17, minute: 0, location: "Innovation Forum", points: "1 Point", house: 1, description: "Eat snacks and chat with students and faculty", day: 15, month: 09, year: 2019, fullDate: "Sun, Sep 15 2019")]

var makeSection: Bool = true

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var whatsHappning: UILabel!
    @IBOutlet weak var eventsTableView: UITableView!
    
    let cellSpacing: CGFloat = 35
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.reloadData()

   //     eventsTableView.tableHeaderView!.frame = CGRectMake(0,0,200,300)
        self.eventsTableView.tableHeaderView = self.eventsTableView.tableHeaderView
        
        eventsTableView.rowHeight = 133
        eventsTableView.sectionHeaderHeight = 2000
        eventsTableView.estimatedSectionHeaderHeight = 2000

        
//Bubble Sort events array
        var done: Bool = false
        var change: Bool = false
        
        if (events.count > 1) {
            while (!done) {
                change = false
                for i in 0...events.count-2 {
                    if events[i].year == events[i+1].year {
                        if events[i].month == events[i+1].month {
                            if events[i].day == events[i+1].day {
                                if events[i].hour == events[i+1].hour{
                                    if events[i].minute > events[i+1].minute {
                                        change = true
                                        let temp: Event = events[i]
                                        events[i] = events[i+1]
                                        events[i+1] = temp
                                    }
                                }
                                if events[i].hour > events[i+1].hour {
                                    change = true
                                    let temp: Event = events[i]
                                    events[i] = events[i+1]
                                    events[i+1] = temp
                                }
                            }
                            if events[i].day > events[i+1].day {
                                change = true
                                let temp: Event = events[i]
                                events[i] = events[i+1]
                                events[i+1] = temp
                            }
                        }
                        else if events[i].month > events[i+1].month {
                            change = true
                            let temp: Event = events[i]
                            events[i] = events[i+1]
                            events[i+1] = temp
                        }
                    }
                    else if events[i].year > events[i+1].year {
                        change = true
                        let temp: Event = events[i]
                        events[i] = events[i+1]
                        events[i+1] = temp
                    }
                }
                if change == false { done = true }
            }
        }
//End of bubble sort

        //Need to remove when putting this into actual HCR App, it will go back to house competition screen
        navigationItem.hidesBackButton = true
    }
    
    

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //makeSection = true
        var header: String = ""
        if section == 0 {
            header = events[section].fullDate
        }
        else {
            if events[section].year == events[section-1].year && events[section].month == events[section-1].month && events[section].day == events[section-1].day { //If it's the same date, don't use a header
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
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell

        //cell.bounds = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width - 40, cell.bounds.size.height)
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        cell.eventName.text = events[indexPath.section].name
        cell.eventDate.text = events[indexPath.section].time
        cell.eventLocation.text = events[indexPath.section].location        
        cell.eventPoints.text = events[indexPath.section].points
        
        //Setting background color based on who the event is for (by house)
        let color = events[indexPath.section].house
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
        cell.eventDescription.text = events[indexPath.section].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 0, y: 0, width: 320, height: self.tableView(eventsTableView, heightForHeaderInSection: section))
        myLabel.font = UIFont.boldSystemFont(ofSize: 26)
        myLabel.text = self.tableView(eventsTableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.addSubview(myLabel)
        
        return headerView
    }
    //Test Comment
}



