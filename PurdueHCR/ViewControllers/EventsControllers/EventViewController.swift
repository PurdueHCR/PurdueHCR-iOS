//
//  ViewController.swift
//  HCR_Calendar
//
//  Created by Brennan Doyle on 9/14/19.
//  Copyright © 2019 Brennan Doyle. All rights reserved.
//

import UIKit

var events: [Event] = [Event(name: "Snack and Chat", location: "Innovation Forum", points: 1, house: "All Houses", details: "Eat snacks and chat with students and faculty and this is going to be a longer description now let's see how this behaves.", fullDate: "Sun, Sep 15 2019", time: "5:00 PM", ownerID: "1234567890")]

var makeSection: Bool = true

class EventViewController: UITableViewController {
    
    
    //@IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var AddEventBarButton: UIBarButtonItem!
    var houseImageView: UIImageView!
    
    let cellSpacing: CGFloat = 35
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //eventTableView.reloadData()//

   //     eventTableView.tableHeaderView!.frame = CGRectMake(0,0,200,300)
        //self.eventTableView.tableHeaderView = self.eventTableView.tableHeaderView
        
        tableView.register(EventTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        self.tableView.rowHeight = 133
        self.tableView.sectionHeaderHeight = 2000
        self.tableView.estimatedSectionHeaderHeight = 2000
        
        events = Event.sortEvents(events: events)
    
        guard let permission = User.get(.permissionLevel) else {
            return
        }
        let p = permission as! Int

        if p == 0 {
            let navigationBar = navigationController!.navigationBar
            self.navigationItem.rightBarButtonItems = nil
            let houseName = User.get(.house) as! String
            houseImageView = UIImageView()
            
            if (houseName == "Platinum"){
                houseImageView.image = #imageLiteral(resourceName: "Platinum")
            }
            else if(houseName == "Copper"){
                houseImageView.image = #imageLiteral(resourceName: "Copper")
            }
            else if(houseName == "Palladium"){
                houseImageView.image = #imageLiteral(resourceName: "Palladium")
            }
            else if(houseName == "Silver"){
                houseImageView.image = #imageLiteral(resourceName: "Silver")
            }
            else if(houseName == "Titanium"){
                houseImageView.image = #imageLiteral(resourceName: "Titanium")
            }
            
            navigationBar.addSubview(houseImageView)
            houseImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
            houseImageView.clipsToBounds = true
            houseImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                houseImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
                houseImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
                houseImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
                houseImageView.widthAnchor.constraint(equalTo: houseImageView.heightAnchor)
            ])
        } else {
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.rightBarButtonItem = AddEventBarButton
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        events = Event.sortEvents(events: events)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Event.numRowsInSection(section: section, events: events)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Event.getNumUniqueDates(events: events)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell

        
        // Currently, due to the borderWidth/Color, shadow does not show up.
//        cell.layer.shadowColor = UIColor.lightGray.cgColor
//        cell.layer.shadowOpacity = 0.5
//        cell.layer.shadowOffset = CGSize.zero
//        cell.layer.shadowRadius = 12
        
        
        let radius: CGFloat = cell.frame.height / 10
        
        cell.layer.cornerRadius = radius
        cell.layer.masksToBounds = true
        
        // Creates vertical space between same-day events (no date in between them)
        cell.layer.borderWidth = 4
        cell.layer.borderColor = UIColor.white.cgColor
                
        let sectionIndex = Event.startingIndexForSection(section: indexPath.section, events: events)
        
        let event = events[sectionIndex + indexPath.row]
        
        cell.eventName.text = event.name
                
        cell.eventDate.text = event.time
        
        
        cell.eventLocation.text = event.location
        if event.points == 1 {
            cell.eventPoints.text = "1 Point"
        } else {
            cell.eventPoints.text = "\(events[sectionIndex + indexPath.row].points) Points"
        }
        
        // Setting background color based on who the event is for (by house)
        let color = event.house
        if color == "Silver" { //Silver, Update Floor
            cell.houseColorView.backgroundColor = UIColor(red: 88/255, green: 196/255, blue: 0/255, alpha: 1.0)

        }
        else if color == "Palladium" { //Palladium, 3rd Floor
            cell.houseColorView.backgroundColor = UIColor.lightGray
        }
        else if color == "Platinum" { //Platinum, 4th Floor
            cell.houseColorView.backgroundColor = UIColor(red: 0/255, green: 218/255, blue: 229/255, alpha: 1.0)
        }
        else if color == "Titanium" { //Titanium, Update Floor
            cell.houseColorView.backgroundColor = UIColor(red: 141/255, green: 113/255, blue: 226/255, alpha: 1.0)

        }
        else if color == "Copper" { //Copper, Update Floor
            cell.houseColorView.backgroundColor = UIColor(red: 247/255, green: 148/255, blue: 0/255, alpha: 1.0)
        } else { // All Houses
            cell.houseColorView.backgroundColor = UIColor(red: 233/255, green: 188/255, blue: 74/255, alpha: 1.0)
        }
        cell.houseColorView.layer.cornerRadius = cell.houseColorView.frame.width / 2
        cell.eventDescription.text = events[sectionIndex + indexPath.row].details
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! EventTableViewHeaderFooterView
        
        header.configureContents()
        
        makeSection = true
        var headerText: String = ""
        if section == 0 {
            headerText = " \(events[section].fullDate)"
        }
        else {
            if events[section].date == events[section - 1].date { //If same date as previous event, don't print date.
                makeSection = false
                return nil
            }
            else {
                headerText = "  \(events[section].fullDate)"
            }
        }
        
        header.title.text = headerText
        
        return header
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewEventTableViewController {
            let viewController = segue.destination as? ViewEventTableViewController
            let eventSender = sender as? EventTableViewCell
            viewController?.cellRow = self.tableView.indexPath(for: eventSender!)!.row
            viewController?.cellSection = self.tableView.indexPath(for: eventSender!)!.section
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
        if (p == 1) {
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

        houseImageView.transform = CGAffineTransform.identity
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



