//
//  ViewEventTableViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 6/27/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class ViewEventTableViewController: UITableViewController, EKEventEditViewDelegate {
    

//    @IBOutlet weak var goingButton: UIButton!
    @IBOutlet weak var iCalExportButton: UIButton!
    @IBOutlet weak var gCalExportButton: UIButton!
    @IBOutlet weak var editEventButton: UIBarButtonItem!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var attendeeLabel: UILabel!
    @IBOutlet weak var detailsLabel: UITextView!
    @IBOutlet weak var hyperlinkLabel: UILabel!
    
    var delegate: EventViewController?
    var going = false // To be set later when connected to database
    var event = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        iCalExportButton.layer.cornerRadius = DefinedValues.radius
        gCalExportButton.layer.cornerRadius = DefinedValues.radius
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let event: Event
//        if (!filtered) {
//            event = events[cellSection + cellRow]
//        } else {
//            event = filteredEvents[cellSection + cellRow]
//        }
        
        let userID = User.get(.id) as! String
        
        if (userID != event.creatorID) {
            editEventButton.isEnabled = false
            editEventButton.tintColor = UIColor.white
        }
        
        self.nameLabel.text = event.name
        //self.nameLabel.numberOfLines = 1
        self.nameLabel.sizeToFit()
        
        let dateFormatter = DateFormatter()
        if (event.startDate == event.endDate) {
            dateFormatter.dateFormat = Event.dateFormat
            self.dateLabel.text = dateFormatter.string(from: event.startDate)
            self.dateLabel.numberOfLines = 1
            self.dateLabel.sizeToFit()
        } else {
            dateFormatter.dateFormat = "E, MM/dd"
            let startDate = dateFormatter.string(from: event.startDate)
            let endDate = dateFormatter.string(from: event.endDate)
            self.dateLabel.text = startDate + " - " + endDate
            self.dateLabel.numberOfLines = 1
            self.dateLabel.sizeToFit()
        }
        
        dateFormatter.dateFormat = Event.timeFormat
        self.timeLabel.text = dateFormatter.string(from: event.startTime) + " - " + dateFormatter.string(from: event.endTime)
        self.timeLabel.numberOfLines = 1
        self.timeLabel.sizeToFit()
        
        self.locationLabel.text = event.location
        self.locationLabel.sizeToFit()
        
        self.hostLabel.text = event.host
        self.hostLabel.sizeToFit()
        
        var floors: String = ""
        if (event.isAllFloors) {
            floors = "All Floors"
        }
        else if (event.isPublicEvent) {
            floors = "Public Event"
        } else {
            var i: Int = 0
            for floor in event.floors {
                if (i == event.floors.count - 1) {
                    floors.append(floor)
                } else {
                    floors.append(floor + ", ")
                }
                i += 1
            }
        }
        
        self.attendeeLabel.text = floors
        self.attendeeLabel.numberOfLines = 1
        self.attendeeLabel.sizeToFit()
        
        if (event.virtualLink != "") {
            self.hyperlinkLabel.text = event.virtualLink
        } else {
            // Empty link so hide the cell
            let hyperlinkCell = tableView.cellForRow(at: IndexPath(row: 5, section: 1))
            NSLayoutConstraint.activate([NSLayoutConstraint(item: hyperlinkCell, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 0)])
        }
        
        self.detailsLabel.text = event.details
        //self.detailsLabel.translatesAutoresizingMaskIntoConstraints = true
        self.detailsLabel.sizeToFit()
        //self.detailsLabel.isScrollEnabled = false
        
//        if (going) {
//            if #available(iOS 13.0, *) {
//                goingButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
//            } else {
//                // Fallback on earlier versions
//            }
//        } else {
//            if #available(iOS 13.0, *) {
//                goingButton.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
//            } else {
//                // Fallback on earlier versions
//            }
//        }
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Preparing")
        if segue.destination is CreateEventTableViewController {
            let viewController = segue.destination as? CreateEventTableViewController
            viewController?.creating = false
            viewController?.event = event
            viewController?.delegate = delegate
        }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exportToiCal(_ sender: Any) {
        let eventStore = EKEventStore()

        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore)
            case .denied:
                print("Access denied")
            case .notDetermined:
                eventStore.requestAccess(to: .event, completion:
                  {[weak self] (granted: Bool, error: Error?) -> Void in
                      if granted {
                        self!.insertEvent(store: eventStore)
                      } else {
                            print("Access denied")
                      }
                })
                default:
                    print("Case default")
        }
    }
    
    @IBAction func exporToGCal(_ sender: Any) {
        let (startDate, endDate) = getCalendarDateFromEventDate(startDate: event.startDate, startTime: event.startTime, endDate: event.endDate, endTime: event.endTime)
        
        let eventName = event.name.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd'T'HHmmss"
        df.timeZone = TimeZone(abbreviation: "ES")
        let startDateString = df.string(from: startDate)
        let endDateString = df.string(from: endDate)
        let urlString = "http://calendar.google.com/?action=create&title=" + eventName + "&dates=" + startDateString + "/" + endDateString
        let url = URL(string: urlString)!
        if UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

         } else {
            //redirect to safari because the user doesn't have Google Calendar
            let safariString = "https://www.google.com/calendar/render?action=TEMPLATE&text=" + eventName + "&dates=" + startDateString + "/" + endDateString
            UIApplication.shared.open(URL(string: safariString)!)
        }
    }
    
    // Inspired by: https://www.ioscreator.com/tutorials/add-event-calendar-ios-tutorial
    func insertEvent(store: EKEventStore) {
        let calendar = store.defaultCalendarForNewEvents
        let iCalEvent = EKEvent(eventStore: store)
        iCalEvent.calendar = calendar
            
        iCalEvent.title = event.name
        
        let (startDate, endDate) = getCalendarDateFromEventDate(startDate: event.startDate, startTime: event.startTime, endDate: event.endDate, endTime: event.endTime)
        
        iCalEvent.startDate = startDate
        iCalEvent.endDate = endDate
        iCalEvent.notes = event.details
        iCalEvent.location = event.location
            
        presentEventCalendarDetailModal(event: iCalEvent, store: store)
    }
    
    func getCalendarDateFromEventDate(startDate:Date, startTime:Date, endDate:Date, endTime:Date) -> (startDate: Date, endDate: Date) {
        // Get the hour and minutes from the start time and add them to the start date
        let tempCal = Calendar.current
        var hour = tempCal.component(.hour, from: event.startTime)
        var minute = tempCal.component(.minute, from: event.startTime)
        var startDate = event.startDate
        startDate = tempCal.date(byAdding: .minute, value: minute, to: startDate) ?? startDate
        startDate = tempCal.date(byAdding: .hour, value: hour, to: startDate) ?? startDate
    
        // Get the hour and minutes from the end time and add them to the end date
        hour = tempCal.component(.hour, from: event.endTime)
        minute = tempCal.component(.minute, from: event.endTime)
        var endDate = event.endDate
        endDate = tempCal.date(byAdding: .minute, value: minute, to: endDate) ?? endDate
        endDate = tempCal.date(byAdding: .hour, value: hour, to: endDate) ?? endDate
        
        return (startDate, endDate)
    }
    
    // Inspired by: https://medium.com/@fede_nieto/manage-calendar-events-with-eventkit-and-eventkitui-with-swift-74e1ecbe2524
    func presentEventCalendarDetailModal(event: EKEvent, store: EKEventStore) {
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = store
        eventModalVC.editViewDelegate = self
        self.present(eventModalVC, animated: true, completion: nil)
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

//    @IBAction func goingAction(_ sender: Any) {
//    
//    
//        if (going) {
//            if #available(iOS 13.0, *) {
//                goingButton.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
//            } else {
//                // Fallback on earlier versions
//            }
//            going = false
//        } else {
//            if #available(iOS 13.0, *) {
//                goingButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
//            } else {
//                // Fallback on earlier versions
//            }
//            going = true
//        }
//        
//    }
    
    
}
