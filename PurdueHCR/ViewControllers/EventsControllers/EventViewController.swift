//
//  ViewController.swift
//  HCR_Calendar
//
//  Created by Brennan Doyle on 9/14/19.
//  Copyright © 2019 Brennan Doyle. All rights reserved.
//

import UIKit
import Firebase

var events: [Event] = [Event]()
var filteredEvents: [Event] = [Event]()
var filtered = false

// Variable to store if child view has asked us to reload
// Should only reload after create, edit, or delete

let fbh = FirebaseHelper()

class EventViewController: UITableViewController {
    
    
    //@IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var AddEventBarButton: UIBarButtonItem!
    @IBOutlet weak var FilterEventsBarButton: UIBarButtonItem!
    
    var shouldReload = false
    var houseImageView: UIImageView!
    
    let cellSpacing: CGFloat = 35
    
    override func viewDidLoad() {
        self.showSpinner(onView: self.view)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //eventTableView.reloadData()//

   //     eventTableView.tableHeaderView!.frame = CGRectMake(0,0,200,300)
        //self.eventTableView.tableHeaderView = self.eventTableView.tableHeaderView
        
        tableView.delegate = self
        tableView.dataSource = self
                
        fbh.getEvents() { (eventsAPI, err) in
            if (err != nil) {
                print("Error in getEvents()")
            } else {
                events = eventsAPI
                
                self.tableView.register(EventTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
                
                self.tableView.rowHeight = 133
                self.tableView.sectionHeaderHeight = 2000
                self.tableView.estimatedSectionHeaderHeight = 2000
                            
                guard let permission = User.get(.permissionLevel) else {
                    return
                }
                let p = permission as! Int

                if p == 0 {
                    let navigationBar = self.navigationController!.navigationBar
                    self.navigationItem.rightBarButtonItems = nil
                    let houseName = User.get(.house) as! String
                    self.houseImageView = UIImageView()
                    
                    if (houseName == "Platinum"){
                        self.houseImageView.image = #imageLiteral(resourceName: "Platinum")
                    }
                    else if(houseName == "Copper"){
                        self.houseImageView.image = #imageLiteral(resourceName: "Copper")
                    }
                    else if(houseName == "Palladium"){
                        self.houseImageView.image = #imageLiteral(resourceName: "Palladium")
                    }
                    else if(houseName == "Silver"){
                        self.houseImageView.image = #imageLiteral(resourceName: "Silver")
                    }
                    else if(houseName == "Titanium"){
                        self.houseImageView.image = #imageLiteral(resourceName: "Titanium")
                    }
                    
                    navigationBar.addSubview(self.houseImageView)
                    self.houseImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
                    self.houseImageView.clipsToBounds = true
                    self.houseImageView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        self.houseImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
                        self.houseImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
                        self.houseImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
                        self.houseImageView.widthAnchor.constraint(equalTo: self.houseImageView.heightAnchor)
                    ])
                    self.FilterEventsBarButton.isEnabled = false
                    self.FilterEventsBarButton.title = ""
                } else {
                    self.navigationItem.rightBarButtonItems = nil
                    self.navigationItem.rightBarButtonItem = self.AddEventBarButton
                    self.FilterEventsBarButton.title = "Filter"
                    self.navigationItem.leftBarButtonItems = nil
                    self.navigationItem.leftBarButtonItem = self.FilterEventsBarButton
                    self.title = "All Events"
                }
                events = Event.sortEvents(events: events)
                self.tableView.reloadData()
                self.removeSpinner()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let selectedRow: IndexPath? = tableView.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            tableView.deselectRow(at: selectedRowNotNill, animated: true)
        }
        //self.showSpinner(onView: self.view)
        guard let permission = User.get(.permissionLevel) else {
            return
        }
        let p = permission as! Int

        if p == 0 {
            houseImageView?.isHidden = false
        }
        
        if (shouldReload) {
            // Child told us to reload data
            shouldReload = false
            reloadData()
        }
    }
    
    func reloadData() {
        if (!filtered) {
            fbh.getEvents() { (eventsAPI, err) in
                if (err != nil) {
                    print("Error in getEvents()")
                    //self.removeSpinner()
                } else {
                    filteredEvents = eventsAPI
                    filteredEvents = Event.sortEvents(events: filteredEvents)
                    self.tableView.reloadData()
                    self.removeSpinner()
                }
            }
        } else {
            fbh.getEventsCreated() { (eventsAPI, err) in
                if (err != nil) {
                    print("Error in getEvents()")
                    //self.removeSpinner()
                } else {
                    events = eventsAPI
                    events = Event.sortEvents(events: events)
                    self.tableView.reloadData()
                    self.removeSpinner()
                }
            }
        }
    }
    
    @IBAction func switchFilter(_ sender: UIBarButtonItem) {
        self.showSpinner(onView: self.view)
        if (!filtered) {
            filtered = true
            self.title = "My Events"
            fbh.getEventsCreated() { (eventsAPI, err) in
                if (err != nil) {
                    print("Error in getEventsCreated()")
                    self.removeSpinner()
                } else {
                    print("Not an error in getEventsCreated()")
                    filteredEvents = eventsAPI
                    filteredEvents = Event.sortEvents(events: filteredEvents)
                    self.tableView.reloadData()
                    self.removeSpinner()
                }
            }
        } else {
            // Unfilter to all events
            self.title = "All Events"
            filtered = false
            fbh.getEvents() { (eventsAPI, err) in
                if (err != nil) {
                    print("Error in getEventsCreated()")
                    self.removeSpinner()
                } else {
                    print("Not an error in getEventsCreated()")
                    events = eventsAPI
                    events = Event.sortEvents(events: events)
                    self.tableView.reloadData()
                    self.removeSpinner()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!filtered) {
            return Event.numRowsInSection(section: section, events: events)
        } else {
            if (filteredEvents.count != 0) {
                return Event.numRowsInSection(section: section, events: filteredEvents)
            } else {
                return 0
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (!filtered) {
            return Event.getNumUniqueDates(events: events)
        } else {
            if (filteredEvents.count != 0) {
                return Event.getNumUniqueDates(events: filteredEvents)
            } else {
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
        
        
        let radius: CGFloat = cell.frame.height / 10
        
        cell.layer.cornerRadius = radius
        cell.layer.masksToBounds = true
        
        // Creates vertical space between same-day events (no date in between them)
        //cell.layer.borderWidth = 4
        //cell.layer.borderColor = UIColor.white.cgColor
         
        let sectionIndex: Int
        if (!filtered) {
            sectionIndex = Event.startingIndexForSection(section: indexPath.section, events: events)
        } else {
            sectionIndex = Event.startingIndexForSection(section: indexPath.section, events: filteredEvents)
        }
        
        let event: Event
        if (!filtered) {
            event = events[sectionIndex + indexPath.row]
        } else {
            event = filteredEvents[sectionIndex + indexPath.row]
        }
        cell.eventIndex = sectionIndex + indexPath.row
        
        cell.eventName.text = event.name
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Event.timeFormat
        cell.eventTime.text = dateFormatter.string(from: event.startTime)
        
        
        cell.eventLocation.text = event.location
        if event.pointType.pointValue == 1 {
            cell.eventPoints.text = "1 Point"
        } else {
            cell.eventPoints.text = "\(event.pointType.pointValue) Points"
        }
        
        // **** Must update this when the colors array is implemented ****
        // Setting background color based on who the event is for (by floors invited)
//        let color = event.house
//        if color == "Silver" { //Silver, Update Floor
//            cell.houseColorView.backgroundColor = UIColor(red: 88/255, green: 196/255, blue: 0/255, alpha: 1.0)
//
//        }
//        else if color == "Palladium" { //Palladium, 3rd Floor
//            cell.houseColorView.backgroundColor = UIColor.lightGray
//        }
//        else if color == "Platinum" { //Platinum, 4th Floor
//            cell.houseColorView.backgroundColor = UIColor(red: 0/255, green: 218/255, blue: 229/255, alpha: 1.0)
//        }
//        else if color == "Titanium" { //Titanium, Update Floor
//            cell.houseColorView.backgroundColor = UIColor(red: 141/255, green: 113/255, blue: 226/255, alpha: 1.0)
//
//        }
//        else if color == "Copper" { //Copper, Update Floor
//            cell.houseColorView.backgroundColor = UIColor(red: 247/255, green: 148/255, blue: 0/255, alpha: 1.0)
//        } else { // All Houses
//            cell.houseColorView.backgroundColor = UIColor(red: 233/255, green: 188/255, blue: 74/255, alpha: 1.0)
//        }
        cell.houseColorView.backgroundColor = UIColor(red: 233/255, green: 188/255, blue: 74/255, alpha: 1.0)
        
        cell.houseColorView.layer.cornerRadius = cell.houseColorView.frame.width / 2
        cell.eventDescription.text = event.details
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }

//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! EventTableViewHeaderFooterView
//
//        header.configureContents()
//
//        var headerText: String = ""
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = Event.dateFormat
//
//
//        if (!filtered) {
//            let sectionIndex = Event.startingIndexForSection(section: section, events: events)
//            headerText = dateFormatter.string(from: events[sectionIndex].startDate)
//        } else {
//            let sectionIndex = Event.startingIndexForSection(section: section, events: filteredEvents)
//            headerText = dateFormatter.string(from: filteredEvents[sectionIndex].startDate)
//        }

//        if section == 0 {
//            if (!filtered) {
//                headerText = dateFormatter.string(from: events[section].startDate)
//            } else {
//                headerText = dateFormatter.string(from: filteredEvents[section].startDate)
//            }
//        }
//        else {
//            if (!filtered) {
//                if events[section].startDate == events[section - 1].startDate { //If same date as previous event, don't print date.
//                    makeSection = false
//                    return nil
//                } else {
//                    headerText = dateFormatter.string(from: events[section].startDate)
//                }
//            } else {
//                if filteredEvents[section].startDate == filteredEvents[section - 1].startDate { //If same date as previous event, don't print date.
//                    makeSection = false
//                    return nil
//                } else {
//                    headerText = dateFormatter.string(from: filteredEvents[section].startDate)
//                }
//            }
//        }
        
//        header.title.text = headerText
//
//        return header
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewEventTableViewController {
            guard let permission = User.get(.permissionLevel) else {
                return
            }
            let p = permission as! Int
            if p == 0 {
                houseImageView.isHidden = true
            }
            let viewController = segue.destination as? ViewEventTableViewController
            let eventSender = sender as? EventTableViewCell
            viewController?.delegate = self
            if (!filtered) {
                viewController?.event = events[eventSender!.eventIndex]
            } else {
                viewController?.event = filteredEvents[eventSender!.eventIndex]
            }
        } else if segue.destination is CreateEventTableViewController {
            let viewController = segue.destination as? CreateEventTableViewController
            viewController?.creating = true
            viewController?.delegate = self
        }
    }
    
    /*
     These last three functions are for handling the house
     image view in the navigation bar
     */
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let permission = User.get(.permissionLevel) else{
            return
        }
        let p = permission as! Int
        if (p == 0) {
            // Normal Resident - Has house logo instead of Add Event button in navigation bar.
            guard let height = navigationController?.navigationBar.frame.height else { return }

            moveAndResizeImage(for: height)
        }
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)

        houseImageView?.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    /// WARNING: Change these constants according to your project's design
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 60
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 16
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
    }
    
    
}
var vSpinner : UIView?
 
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}




