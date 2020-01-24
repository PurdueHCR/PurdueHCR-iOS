//
//  CreateEventViewController.swift
//  HCR_Calendar
//
//  Created by Brennan Doyle on 9/14/19.
//  Copyright © 2019 Brennan Doyle. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var newEventName: UITextField!
    @IBOutlet weak var newEventDate: UIDatePicker!
    @IBOutlet weak var newEventLocation: UITextField!
    @IBOutlet weak var newEventPoints: UISegmentedControl!
    @IBOutlet weak var newEventDescription: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var newEventButton: UIButton!
    
    let houses = ["All Houses", "Silver", "Palladium", "Platinum", "Titanium", "Copper"]
    var houseI = 1
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return houses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return houses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let house = houses[row]
        
        if (house == "All Houses") { houseI = 1 }
        else if (house == "Silver") { houseI = 2 }
        else if (house == "Palladium") { houseI = 3 }
        else if (house == "Platinum") { houseI = 4 }
        else if (house == "Titanium") { houseI = 5 }
        else if (house == "Copper") { houseI = 6 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pickerView.delegate = self
        pickerView.dataSource = self
        
        newEventButton.layer.cornerRadius = 4
    }
    
    @IBAction func createNewEvent(_ sender: Any) {

        let name = newEventName.text!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let time = dateFormatter.string(from: newEventDate.date)
        dateFormatter.dateFormat = "HH"
        let hour = Int(dateFormatter.string(from: newEventDate.date))!
        dateFormatter.dateFormat = "mm"
        let minute = Int(dateFormatter.string(from: newEventDate.date))!
        dateFormatter.dateFormat = "dd"
        let day = Int(dateFormatter.string(from: newEventDate.date))!
        dateFormatter.dateFormat = "MM"
        let month = Int(dateFormatter.string(from: newEventDate.date))!
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: newEventDate.date))!
        dateFormatter.dateFormat = "E, MMM d yyyy"
        let fullDate = dateFormatter.string(from: newEventDate.date)
        
        let location = newEventLocation.text!
        
        // Points may be something we want to change from this to a text input.
        let pointsI = newEventPoints.selectedSegmentIndex
        var points = 0
        if pointsI == 0 {
            points = 1
        }
        else if pointsI == 1 {
            points = 3
        }
        else if pointsI == 2 {
            points = 5
        }
        else if pointsI == 3 {
            points = 10
        }
        
        let description = newEventDescription.text!
        
        // This is something to be implemented once we connect the database!
        let ownerID = "0987654321"
        

        events.append(Event(name: name, time: time, hour: hour, minute: minute, location: location, points: points, house: houseI, description: description, day: day, month: month, year: year, fullDate: fullDate, ownerID: ownerID))
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
