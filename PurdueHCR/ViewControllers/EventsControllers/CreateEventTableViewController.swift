//
//  CreateEventTableViewController.swift
//  PurdueHCR
//
//  Created by Brennan Doyle on 2/10/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit
import Firebase

class CreateEventTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
     
    @IBOutlet weak var newEventName: UITextField!
    @IBOutlet weak var newEventStartDate: UIDatePicker!
    @IBOutlet weak var newEventEndDate: UIDatePicker!
    @IBOutlet weak var newEventLocation: UITextField!
    @IBOutlet weak var newEventMyFloorLabel: UILabel!
    @IBOutlet weak var newEventMyFloorSwitch: UISwitch!
    @IBOutlet weak var newEventMyHouseSwitch: UISwitch!
    @IBOutlet weak var newEventAllHousesSwitch: UISwitch!
    @IBOutlet weak var newEventIsPublicLabel: UILabel!
    @IBOutlet weak var newEventIsPublicSwitch: UISwitch!
    @IBOutlet weak var newEventCustomFloorButton: UIButton!
    @IBOutlet weak var newEventDescription: UITextField!
    @IBOutlet weak var newEventPointType: UIPickerView!
    @IBOutlet weak var hostEventSwitch: UISwitch!
    @IBOutlet weak var chooseHostField: UITextField!
    @IBOutlet weak var createEventButton: UIButton!
    
    
    let fbh = FirebaseHelper()
    var floorsSelected: [String] = [String]()
    var pointTypes: [PointType] = [PointType]()
    var pointTypesIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newEventPointType.delegate = self
        newEventPointType.dataSource = self
        
        createEventButton.layer.cornerRadius = 4
        
        chooseHostField.isEnabled = false
        chooseHostField.textColor = UIColor.gray
        
        newEventMyFloorSwitch.isOn = true
        newEventMyHouseSwitch.isOn = false
        newEventAllHousesSwitch.isOn = false
        newEventIsPublicSwitch.isOn = false
        newEventIsPublicSwitch.isEnabled = false
        newEventIsPublicLabel.textColor = UIColor.gray
        
        
        pointTypes = DataManager.sharedManager.getPoints()!
//        for type in pointTypes {
//            print("Pre Point Type: " + type.pointName)
//        }
        pointTypes = DataManager.filter(points: DataManager.sharedManager.getPoints()!)
//        for pointType in pointTypes {
//            print("Post Point Type: " + pointType.pointName)
//        }
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        let p = User.get(.permissionLevel) as! Int
        if (p == 3) {
            disableFhpFloorsInvited()
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
        return 9
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.selectionStyle = .none
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pointTypes[row].pointName
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pointTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pointTypesIndex = row
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
    
    
    @IBAction func createNewEvent(_ sender: Any) {
        let name = newEventName.text!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Event.dateFormat + " " + Event.timeFormat
        let startDateTime = dateFormatter.string(from: newEventStartDate.date)
        let endDateTime = dateFormatter.string(from: newEventEndDate.date)
        
        let location = newEventLocation.text!
        
        let pointType = pointTypes[pointTypesIndex]
        
        let host: String
        if hostEventSwitch.isOn {
            host = "Creator"
        } else {
            host = chooseHostField.text!
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
            if (p == 3) {
                floors = convertHouseToFloors()
            } else {
                let floorId = User.get(.floorID) as! String
                print("floorId" + floorId)
                let startIndex = floorId.startIndex
                let northSouthIndex = floorId.index(after: startIndex)
                var floor2: String = ""
                if (floorId[northSouthIndex] == "N") {
                    floor2 = "" + String(floorId.first!) + "S"
                } else if (floorId[northSouthIndex] == "S") {
                    floor2 = "" + String(floorId.first!) + "N"
                } else {
                    print("Error with second floor")
                }
                
                floors.append(floorId)
                floors.append(floor2)
            }
        } else if (newEventAllHousesSwitch.isOn) {
            isAllFloors = true
            if (newEventIsPublicSwitch.isOn) {
                isPublicEvent = true
            }
        } else {
            floors = floorsSelected
        }
        
        let details = newEventDescription.text!
        
        guard let id = User.get(.id) else {
            return
        }
        let creatorID = id as! String
        
        let event = Event(name: name, location: location, pointType: pointType, floors: floors, details: details, isPublicEvent: isPublicEvent, isAllFloors: isAllFloors, startDateTime: startDateTime, endDateTime: endDateTime, creatorID: creatorID, host: host)
        events.append(event)
        
        print("Calling Add Event")
        // FIRE BASE HELPER METHOD TO ADD EVENT
        fbh.addEvent(event: event) { (err) in
            if (err != nil) {
                
            } else {
                print("No Error")
            }
        }
        
        
        performSegueToReturnBack()
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
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
