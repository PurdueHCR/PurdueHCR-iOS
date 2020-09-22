//
//  CreateEventTableViewController.swift
//  PurdueHCR
//
//  Created by Brennan Doyle on 2/10/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

class CreateEventTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
     
    @IBOutlet weak var newEventName: UITextField!
    @IBOutlet weak var newEventDate: UIDatePicker!
    @IBOutlet weak var newEventLocation: UITextField!
    @IBOutlet weak var newEventPoints: UISegmentedControl!
    @IBOutlet weak var newEventDescription: UITextField!
    @IBOutlet weak var housePickerView: UIPickerView!
    @IBOutlet weak var createEventButton: UIButton!
    
    let houses = ["All Houses", "Silver", "Palladium", "Platinum", "Titanium", "Copper"]
    var houseI = "All Houses"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        housePickerView.delegate = self
        housePickerView.dataSource = self
        
        createEventButton.layer.cornerRadius = 4
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
        return 7
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return houses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return houses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        houseI = houses[row]
    }
    
    @IBAction func createNewEvent(_ sender: Any) {

        let name = newEventName.text!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let time = dateFormatter.string(from: newEventDate.date)
        
        dateFormatter.dateFormat = "E, MMM d yyyy"
        let fullDate = dateFormatter.string(from: newEventDate.date)
        
        
        let date = newEventDate.date
        
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
        
        let details = newEventDescription.text!
        
        // This is something to be implemented once we connect the database!
        let ownerID = "0987654321"
        
        events.append(Event(name: name, location: location, points: points, house: houseI, details: details, fullDate: fullDate, time: time, ownerID: ownerID))
        
        performSegueToReturnBack()
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
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
