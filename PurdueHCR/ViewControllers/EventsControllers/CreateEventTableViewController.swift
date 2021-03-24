//
//  CreateEventTableViewController.swift
//  PurdueHCR
//
//  Created by Brennan Doyle on 2/10/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit
import Firebase

class CreateEventTableViewController: UITableViewController, UITextViewDelegate {
     
    @IBOutlet weak var newEventName: UITextField!
    @IBOutlet weak var newEventStartDate: UIDatePicker!
    @IBOutlet weak var newEventEndDate: UIDatePicker!
    @IBOutlet weak var newEventLocation: UITextField!
    @IBOutlet weak var newEventMyFloorLabel: UILabel!
    @IBOutlet weak var newEventMyFloorSwitch: UISwitch!
    @IBOutlet weak var newEventMyHouseSwitch: UISwitch!
    @IBOutlet weak var newEventMyHouseLabel: UILabel!
    @IBOutlet weak var newEventAllHousesSwitch: UISwitch!
    @IBOutlet weak var newEventIsPublicLabel: UILabel!
    @IBOutlet weak var newEventIsPublicSwitch: UISwitch!
    @IBOutlet weak var newEventCustomFloorButton: UIButton!
    @IBOutlet weak var newEventDescription: UITextView!
    @IBOutlet weak var newEventPointType: UIButton!
    @IBOutlet weak var hostEventSwitch: UISwitch!
    @IBOutlet weak var chooseHostField: UITextField!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var deleteEventButton: UIButton!
    
    
    let fbh = FirebaseHelper()
    var floorsSelected: [String] = [String]()
    static var pointTypes: [PointType] = [PointType]()
    static var pointTypesIndex = -1
    
    var delegate: EventViewController?
    
    var creating: Bool = true // True if view is for creating and event. False if view is for editing/deleting an event.
    var event = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
                
        createEventButton.layer.cornerRadius = DefinedValues.radius
        deleteEventButton.layer.cornerRadius = DefinedValues.radius
        
        chooseHostField.isEnabled = false
        chooseHostField.textColor = UIColor.gray
        
        newEventDescription.text = "";
        
        if (User.get(.permissionLevel) as! Int == PointType.PermissionLevel.ea.rawValue) {
            // EAs don't have a house or floor
            newEventMyFloorSwitch.isOn = false
            newEventMyHouseSwitch.isOn = false
            newEventAllHousesSwitch.isOn = true
            newEventIsPublicSwitch.isOn = false
            newEventIsPublicSwitch.isEnabled = true
            
            newEventIsPublicLabel.textColor = UIColor.black
            newEventMyFloorLabel.textColor = UIColor.gray
            newEventMyHouseLabel.textColor = UIColor.gray
            
            newEventMyFloorSwitch.isEnabled = false
            newEventMyHouseSwitch.isEnabled = false
            newEventCustomFloorButton.isHidden = true
        } else {
            newEventMyFloorSwitch.isOn = true
            newEventMyHouseSwitch.isOn = false
            newEventAllHousesSwitch.isOn = false
            newEventIsPublicSwitch.isOn = false
            newEventIsPublicSwitch.isEnabled = false
            
            newEventIsPublicLabel.textColor = UIColor.gray
        }
        
        
        newEventName.backgroundColor = UIColor(red:238.0/255.0,green:238.0/255.0,blue:239.0/255.0,alpha: 1.0)
        
        newEventLocation.backgroundColor = UIColor(red:238.0/255.0,green:238.0/255.0,blue:239.0/255.0,alpha: 1.0)
        
        newEventDescription.backgroundColor = UIColor(red:238.0/255.0,green:238.0/255.0,blue:239.0/255.0,alpha: 1.0)
        
        chooseHostField.backgroundColor = UIColor(red:238.0/255.0,green:238.0/255.0,blue:239.0/255.0,alpha: 1.0)
        
        CreateEventTableViewController.pointTypes = DataManager.filter(points: DataManager.sharedManager.getPoints()!)
        
        newEventStartDate.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (creating) {
            if (floorsSelected.isEmpty) {
                newEventCustomFloorButton.setTitle("Custom...", for: .normal)
                if (!newEventMyHouseSwitch.isOn && !newEventMyFloorSwitch.isOn && !newEventAllHousesSwitch.isOn) {
                    newEventMyFloorSwitch.isOn = true
                }
            } else if (floorsSelected.count == 9) {
                newEventAllHousesSwitch.isOn = true
                newEventMyFloorSwitch.isOn = false
                newEventMyHouseSwitch.isOn = false
                newEventIsPublicSwitch.isOn = false
                newEventIsPublicSwitch.isEnabled = true
                newEventIsPublicLabel.textColor = UIColor.black
                floorsSelected.removeAll()
                newEventCustomFloorButton.setTitle("Custom...", for: .normal)
            } else {
                newEventMyFloorSwitch.isOn = false
                newEventMyHouseSwitch.isOn = false
                newEventAllHousesSwitch.isOn = false
                
                var floorString = ""
                var i = 0
                for floor in floorsSelected {
                    floorString.append(floor)
                    if (i != floorsSelected.count - 1) {
                        floorString.append(", ")
                    }
                    i += 1
                }
                newEventCustomFloorButton.setTitle(floorString, for: .normal)
            }
            
            print("Create" + String(CreateEventTableViewController.pointTypesIndex))
            if (CreateEventTableViewController.pointTypesIndex != -1) {
                newEventPointType.setTitle(CreateEventTableViewController.pointTypes[CreateEventTableViewController.pointTypesIndex].pointName, for: .normal)
            } else {
                newEventPointType.setTitle("Select Point Type...", for: .normal)
            }
            
            createEventButton.isEnabled = true
            let p = User.get(.permissionLevel) as! Int
            if (p == PointType.PermissionLevel.faculty.rawValue) {
                disableFhpFloorsInvited()
            }
        } else {
            newEventName.text = event.name
            newEventLocation.text = event.location
            newEventDescription.text = event.details
            
            let firstName = User.get(.firstName) as! String
            let lastName = User.get(.lastName) as! String
            if (event.host != (firstName + " " + lastName)) {
                hostEventSwitch.isOn = false
                chooseHostField.text = event.host
                chooseHostField.isEnabled = true
                chooseHostField.textColor = UIColor.black
            } else {
                hostEventSwitch.isOn = true
                chooseHostField.isEnabled = false
                chooseHostField.textColor = UIColor.gray
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Event.dateFormat
            let startDateString = dateFormatter.string(from: event.startDate)
            let endDateString = dateFormatter.string(from: event.endDate)
            dateFormatter.dateFormat = Event.timeFormat
            let startTimeString = dateFormatter.string(from: event.startTime)
            let endTimeString = dateFormatter.string(from: event.endTime)
            dateFormatter.dateFormat = Event.dateFormat + " " + Event.timeFormat
            let startDateTime = dateFormatter.date(from: startDateString + " " + startTimeString)
            let endDateTime = dateFormatter.date(from: endDateString + " " + endTimeString)
            newEventStartDate.date = startDateTime!
            newEventEndDate.date = endDateTime!
            
            var pointTypeIndex = 0
            for pointType in CreateEventTableViewController.pointTypes {
                if (pointType.pointID == event.pointType.pointID) {
                    CreateEventTableViewController.pointTypesIndex = pointTypeIndex
                    break
                }
                pointTypeIndex += 1
            }
            newEventPointType.setTitle(CreateEventTableViewController.pointTypes[CreateEventTableViewController.pointTypesIndex].pointName, for: .normal)
            
            if (event.isAllFloors) {
                newEventAllHousesSwitch.isOn = true
                newEventMyFloorSwitch.isOn = false
                newEventMyHouseSwitch.isOn = false
                if (event.isPublicEvent) {
                    newEventIsPublicSwitch.isOn = true
                } else {
                    newEventIsPublicSwitch.isOn = false
                }
                newEventIsPublicSwitch.isEnabled = true
                newEventIsPublicLabel.textColor = UIColor.black
                newEventCustomFloorButton.setTitle("Custom...", for: .normal)
            } else {
                floorsSelected = event.floors
                let creatorFloor = getCreatorFloor()
                if (floorsSelected.count == 1) {
                    if (floorsSelected[0] == creatorFloor) {
                        newEventMyFloorSwitch.isOn = true
                    } else {
                        newEventCustomFloorButton.setTitle(floorsSelected[0], for: .normal)
                        newEventMyFloorSwitch.isOn = false
                    }
                    newEventMyHouseSwitch.isOn = false
                    newEventAllHousesSwitch.isOn = false
                    newEventIsPublicSwitch.isOn = false
                    newEventIsPublicSwitch.isEnabled = false
                    newEventIsPublicLabel.textColor = UIColor.gray
                } else if (floorsSelected.count == 2) {
                    // Check for MyHouse
                    let startIndex = creatorFloor.startIndex
                    let northSouthIndex = creatorFloor.index(after: startIndex)
                    var floor2: String = ""
                    if (creatorFloor[northSouthIndex] == "N") {
                        floor2 = String(creatorFloor.first!) + "S"
                    } else {
                        floor2 = String(creatorFloor.first!) + "N"
                    }
                    
                    if (creatorFloor == floorsSelected[0]) {
                        if (floor2 == floorsSelected[1]) {
                            newEventMyFloorSwitch.isOn = false
                            newEventMyHouseSwitch.isOn = true
                            newEventAllHousesSwitch.isOn = false
                            newEventIsPublicSwitch.isOn = false
                            newEventIsPublicSwitch.isEnabled = false
                            newEventIsPublicLabel.textColor = UIColor.gray                        }
                    } else if (floor2 == floorsSelected[0]) {
                        if (creatorFloor == floorsSelected[1]) {
                            newEventMyFloorSwitch.isOn = false
                            newEventMyHouseSwitch.isOn = true
                            newEventAllHousesSwitch.isOn = false
                            newEventIsPublicSwitch.isOn = false
                            newEventIsPublicSwitch.isEnabled = false
                            newEventIsPublicLabel.textColor = UIColor.gray
                        }
                    } else {
                        var floorString: String = ""
                        var i = 0
                        for floor in floorsSelected {
                            floorString.append(floor)
                            if (i != floorsSelected.count - 1) {
                                floorString.append(", ")
                            }
                            i += 1
                        }
                        newEventCustomFloorButton.setTitle(floorString, for: .normal)
                        newEventMyFloorSwitch.isOn = false
                        newEventMyHouseSwitch.isOn = false
                        newEventAllHousesSwitch.isOn = false
                        newEventIsPublicSwitch.isOn = false
                        newEventIsPublicSwitch.isEnabled = false
                        newEventIsPublicLabel.textColor = UIColor.gray
                    }
                } else {
                    var floorString: String = ""
                    var i = 0
                    for floor in floorsSelected {
                        floorString.append(floor)
                        if (i != floorsSelected.count - 1) {
                            floorString.append(", ")
                        }
                        i += 1
                    }
                    newEventCustomFloorButton.setTitle(floorString, for: .normal)
                    newEventMyFloorSwitch.isOn = false
                    newEventMyHouseSwitch.isOn = false
                    newEventAllHousesSwitch.isOn = false
                    newEventIsPublicSwitch.isOn = false
                    newEventIsPublicSwitch.isEnabled = false
                    newEventIsPublicLabel.textColor = UIColor.gray
                }
            }
            let p = User.get(.permissionLevel) as! Int
            if (p == PointType.PermissionLevel.faculty.rawValue) {
                if (newEventMyFloorSwitch.isOn) {
                    newEventMyFloorSwitch.isOn = false
                    newEventMyHouseSwitch.isOn = true
                }
                newEventMyFloorSwitch.isEnabled = false
                newEventMyFloorLabel.textColor = UIColor.gray
            }
            
            floorsSelected = event.floors
            
            createEventButton.setTitle("Update Event", for: .normal)
            createEventButton.isEnabled = true
            deleteEventButton.isEnabled = true
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (creating) {
            return 9
        } else {
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.selectionStyle = .none
        return nil
    }
    
    func disableFhpFloorsInvited() {
        if (newEventMyFloorSwitch.isOn) {
            newEventMyFloorSwitch.isOn = false
            newEventMyHouseSwitch.isOn = true
            newEventAllHousesSwitch.isOn = false
            newEventIsPublicSwitch.isOn = false
            newEventIsPublicSwitch.isEnabled = false
            newEventIsPublicLabel.textColor = UIColor.gray
        }
        newEventMyFloorSwitch.isEnabled = false
        newEventMyFloorLabel.textColor = UIColor.gray
    }
    
    func getCreatorFloor() -> String {
        let p = User.get(.permissionLevel) as! Int
        if (p == 3) {
            return convertHouseToFloors()[0]
        }
        return User.get(.floorID) as! String
    }
    
    func convertHouseToFloors() -> [String] {
        let house = User.get(.house) as! String
        var floorsInvited = [String]()
        if (house == "Copper") {
            floorsInvited.append("2N")
            floorsInvited.append("2S")
        } else if (house == "Palladium") {
            floorsInvited.append("3N")
            floorsInvited.append("3S")
        } else if (house == "Platinum") {
            floorsInvited.append("4N")
            floorsInvited.append("4S")
        } else if (house == "Silver") {
            floorsInvited.append("5N")
            floorsInvited.append("5S")
        } else if (house == "Titanium") {
            floorsInvited.append("6N")
            floorsInvited.append("6S")
        }
        return floorsInvited
    }
    
    @IBAction func hostEventSwitch(_ sender: UISwitch) {
        if (sender.isOn) {
            chooseHostField.isEnabled = false
            chooseHostField.textColor = UIColor.gray
        } else {
            chooseHostField.isEnabled = true
            chooseHostField.textColor = UIColor.black
        }
    }

    @IBAction func floorInviteSwitch(_ sender: UISwitch) {
        if (sender == newEventMyFloorSwitch) {
            if (newEventMyFloorSwitch.isOn) {
                newEventMyHouseSwitch.isOn = false
                newEventAllHousesSwitch.isOn = false
                newEventIsPublicSwitch.isOn = false
                newEventIsPublicSwitch.isEnabled = false
                newEventIsPublicLabel.textColor = UIColor.gray
                newEventCustomFloorButton.setTitle("Custom...", for: .normal)
            }
        } else if (sender == newEventMyHouseSwitch) {
            if (newEventMyHouseSwitch.isOn) {
                newEventMyFloorSwitch.isOn = false
                newEventAllHousesSwitch.isOn = false
                newEventIsPublicSwitch.isOn = false
                newEventIsPublicSwitch.isEnabled = false
                newEventIsPublicLabel.textColor = UIColor.gray
                newEventCustomFloorButton.setTitle("Custom...", for: .normal)
            }
        } else if (sender == newEventAllHousesSwitch) {
            if (newEventAllHousesSwitch.isOn) {
                newEventMyFloorSwitch.isOn = false
                newEventMyHouseSwitch.isOn = false
                newEventCustomFloorButton.setTitle("Custom...", for: .normal)
                
                newEventIsPublicSwitch.isOn = false
                newEventIsPublicSwitch.isEnabled = true
                newEventIsPublicLabel.textColor = UIColor.black
            } else {
                newEventIsPublicSwitch.isOn = false
                newEventIsPublicSwitch.isEnabled = false
                newEventIsPublicLabel.textColor = UIColor.gray
            }
        }
    }
    
    @IBAction func createOrEditEvent(_ sender: UIButton) {
        print("Create or edit")
        createEventButton.isEnabled = false
        let newEvent = createNewEvent()
        if (newEvent == nil) {
            self.notify(title: "Please fill out all fields correctly", subtitle: "", style: .danger)
            self.createEventButton.isEnabled = true
            return
        }
        if (creating) {
            //events.append(newEvent)
            
            // FIRE BASE HELPER METHOD TO ADD EVENT
            fbh.addEvent(event: newEvent!) { (err) in
                if (err != nil) {
                    self.notify(title: "Error Creating Event", subtitle: "", style: .danger)
                    self.createEventButton.isEnabled = true
                } else {
                    
                    self.fbh.getEvents() { (eventsAPI, err) in
                        if (err != nil) {
                            print("Error in getEvents()")
                        } else {
                            print("No error creating event")
                            self.delegate?.shouldReload = true
                            events = eventsAPI
                            self.createEventButton.isEnabled = true
                            self.performSegueToReturnBack(fromEdit: false, event: nil)
                        }
                    }
                }
            }
        } else {
            fbh.editEvent(event: newEvent!, origID: event.eventID) { (err, event) in
                if (err != nil) {
                    self.notify(title: "Error Editing Event", subtitle: "", style: .danger)
                    self.createEventButton.isEnabled = true
                } else {
                    print("No error in Edit")
                    
                    self.fbh.getEvents() { (eventsAPI, err) in
                        if (err != nil) {
                            print("Error in getEvents() inside editEvents()")
                        } else {
                            self.delegate?.shouldReload = true
                            events = eventsAPI
                            self.performSegueToReturnBack(fromEdit: true, event: event)
                            self.createEventButton.isEnabled = true
                        }
                    }
                }
            }
        }
    }
    
    func createNewEvent() -> Event? {
        let name = newEventName.text!
        if (name == "" || name == "Name...") {
            return nil
        }
        
        let startDate = newEventStartDate.date
        let endDate = newEventEndDate.date
        if (endDate < startDate) {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Event.dateFormat + " " + Event.timeFormat
        let startDateTime = dateFormatter.string(from: startDate)
        let endDateTime = dateFormatter.string(from: endDate)
        
        let location = newEventLocation.text!
        if (location == "" || location == "Location...") {
            return nil
        }
        
        if (CreateEventTableViewController.pointTypesIndex == -1) {
            return nil
        }
        let pointType = CreateEventTableViewController.pointTypes[CreateEventTableViewController.pointTypesIndex]
        
        let host: String
        if hostEventSwitch.isOn {
            let firstName = User.get(.firstName) as! String
            let lastName = User.get(.lastName) as! String
            host = firstName + " " + lastName
        } else {
            host = chooseHostField.text!
            if (host == "" || host == "Specify Host...") {
                return nil
            }
        }
        
        var floors = [String]()
        var isAllFloors = false
        var isPublicEvent = false
        if (newEventMyFloorSwitch.isOn) {
            let floorId = User.get(.floorID) as! String
            print("FloorID: " + floorId)
            floors.append(floorId)
        } else if (newEventMyHouseSwitch.isOn) {
            let p = User.get(.permissionLevel) as! Int
            if (p == PointType.PermissionLevel.faculty.rawValue) {
                floors = convertHouseToFloors()
            } else {
                let floorId = User.get(.floorID) as! String
                print("floorId" + floorId)
                let startIndex = floorId.startIndex
                let northSouthIndex = floorId.index(after: startIndex)
                var floor2: String = ""
                if (floorId[northSouthIndex] == "N") {
                    floor2 = "" + String(floorId.first!) + "S"
                    floors.append(floorId)
                    floors.append(floor2)
                } else if (floorId[northSouthIndex] == "S") {
                    floor2 = "" + String(floorId.first!) + "N"
                    floors.append(floorId)
                    floors.append(floor2)
                } else {
                    print("Error with second floor")
                }
            }
        } else if (newEventAllHousesSwitch.isOn) {
            isAllFloors = true
            if (newEventIsPublicSwitch.isOn) {
                isPublicEvent = true
            }
        } else {
            if (floorsSelected.isEmpty) {
                return nil
            }
            floors = floorsSelected
        }
        
        let details = newEventDescription.text!
        if (details == "") {
            return nil
        }
        
        let creatorID = User.get(.id) as! String
        
        return Event(name: name, location: location, pointType: pointType, floors: floors, details: details, isPublicEvent: isPublicEvent, isAllFloors: isAllFloors, startDateTime: startDateTime, endDateTime: endDateTime, creatorID: creatorID, host: host)
    }
    
    @IBAction func deleteEvent(_ sender: UIButton) {
        // This option isn't in the API unless you call edit and pass a null event.
        // If this is the case, call edit API and then call read API.
        print("Calling delete event")
        
        deleteEventButton.isEnabled = false

        fbh.deleteEvent(origID: event.eventID) { (err) in
            if (err != nil) {
                self.deleteEventButton.isEnabled = true
                self.notify(title: "Error Deleting Event", subtitle: "", style: .danger)
            } else {
                print("No eror")
                
                self.fbh.getEvents() { (eventsAPI, err) in
                    if (err != nil) {
                        print("Error in getEvents() inside editEvents()")
                    } else {
                        print("Not an error in getEvents() inside editEvents()")
                        events = eventsAPI
                        self.performSegueToReturnBack(fromEdit: false, event: nil)
                        self.performSegueToReturnBack(fromEdit: false, event: nil)
                        self.deleteEventButton.isEnabled = true
                        self.delegate?.shouldReload = true
                    }
                }
            }
        }
    }
    
    func performSegueToReturnBack(fromEdit: Bool, event: Event?)  {
        if let nav = self.navigationController {
            if (fromEdit) {
                nav.popViewController(animated: true)
                let nextController = nav.topViewController as! ViewEventTableViewController
                nextController.event = event!
            } else {
                nav.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.newEventMyFloorSwitch.isOn = false
        self.newEventMyHouseSwitch.isOn = false
        if (segue.destination is SelectFloorsTableViewController) {
            let dest = segue.destination as! SelectFloorsTableViewController
            dest.delegate = self
        }
        if (segue.destination is SelectPointTypeTableViewController) {
            let dest = segue.destination as! SelectPointTypeTableViewController
            dest.delegate = self
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let startDate = sender.date
        // Make end date the start date plus 1 hour
        let endDate = startDate.addingTimeInterval(TimeInterval(3600))
        newEventEndDate.date = endDate
    }
    
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if self.view.window != nil {
//            if textView.textColor == UIColor.lightGray {
//                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//            }
//        }
//    }
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        if text == "\n" {
//            textView.resignFirstResponder()
//            return false
//        }
//
//        let currentText:String = textView.text
//        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
//
//        if updatedText.isEmpty {
//
//            //textView.text = placeholder
//            textView.textColor = UIColor.lightGray
//
//            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//        }
//
//        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
//            textView.textColor = UIColor.black
//            textView.text = ""
//        }
//
//        return updatedText.count <= 240
//    }
//
//    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
//        self.newEventDescription.resignFirstResponder()
//    }
//
//    var hasMoved = false
//
//    /// Runs when the keyboard will appear on the screen
//    @objc func keyboardWillShow(notification: NSNotification) {
//        // Check if the screen has already been shifted up
//        if (!hasMoved) {
//            // Get the size of the current keyboard
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//
//                // Location of the top of the keyboard on the screen
//                let height = self.view.frame.height - keyboardSize.height - tabBarController!.tabBar.frame.height
//                // Check if keyboard is above the bottom of the text field
//                if (self.newEventDescription.frame.maxY > height) {
//                    let diff = self.newEventDescription.frame.maxY - height
//                    // Move the view up
//                    self.view.frame.origin.y -= (diff + 20)
//                    hasMoved = true
//                }
//            }
//        }
//    }
//
//
//    /// Runs when the keyboard will disappear from the screen
//    @objc func keyboardWillHide(notification: NSNotification) {
//        // Restore the view to it's normal location in case it has been
//        //  pushed up to accommodate the keyboard
//        self.view.frame.origin.y = 0
//        hasMoved = false
//    }
//
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateEventTableViewController: SelectFloorsDelegate {
    func updateData(selected: [Bool], floors: [String]) {
        var i = 0;
        floorsSelected = [String]()
        for floor in selected {
            if (floor) {
                floorsSelected.append(floors[i])
            }
            i += 1
        }
    }
}

extension CreateEventTableViewController: SelectPointTypeDelegate {
    func updatePointTypeData(pointTypeSelected: Int) {
        print("In the extension")
        CreateEventTableViewController.pointTypesIndex = pointTypeSelected
        print("New val: " + String(CreateEventTableViewController.pointTypesIndex))
    }
}
