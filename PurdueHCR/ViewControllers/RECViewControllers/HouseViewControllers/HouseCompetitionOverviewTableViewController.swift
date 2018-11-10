//
//  HouseCompetitionOverviewTableViewController.swift
//  PurdueHCR
//
//  Created by Brian Johncox on 10/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class HouseCompetitionOverviewTableViewController: UITableViewController {

    
    let houses = ["Copper","Palladium","Platinum","Silver","Titanium"]
    @IBOutlet var houseSelectionControl: UISegmentedControl!
    @IBOutlet var firstPlaceLabel: UILabel!
    @IBOutlet var firstPointsLabel: UILabel!
    @IBOutlet var secondPlaceLabel: UILabel!
    @IBOutlet var secondPointsLabel: UILabel!
    @IBOutlet var thirdPlaceLabel: UILabel!
    @IBOutlet var thirdPointsLabel: UILabel!
    @IBOutlet var fourthPlaceLabel: UILabel!
    @IBOutlet var fourthPointsLabel: UILabel!
    @IBOutlet var fifthPlaceLabel: UILabel!
    @IBOutlet var fifthPointsLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceLabels(house: getHouseWithName(name: "Copper")!)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func setPlaceLabels(house:House){
        firstPlaceLabel.text = "No User"
        firstPointsLabel.text = ""
        secondPlaceLabel.text = "No User"
        secondPointsLabel.text = ""
        thirdPlaceLabel.text = "No User"
        thirdPointsLabel.text = ""
        fourthPlaceLabel.text = "No User"
        fourthPointsLabel.text = ""
        fifthPlaceLabel.text = "No User"
        fifthPointsLabel.text = ""
        if(house.topScoreUsers!.count > 0){
            firstPlaceLabel.text = house.topScoreUsers![0].userName
            firstPointsLabel.text = house.topScoreUsers![0].totalPoints.description
        }
        if(house.topScoreUsers!.count > 1){
            secondPlaceLabel.text = house.topScoreUsers![1].userName
            secondPointsLabel.text = house.topScoreUsers![1].totalPoints.description
        }
        if(house.topScoreUsers!.count > 2){
            thirdPlaceLabel.text = house.topScoreUsers![2].userName
            thirdPointsLabel.text = house.topScoreUsers![2].totalPoints.description
        }
        if(house.topScoreUsers!.count > 3){
            fourthPlaceLabel.text = house.topScoreUsers![3].userName
            fourthPointsLabel.text = house.topScoreUsers![3].totalPoints.description
        }
        if(house.topScoreUsers!.count > 4){
            fifthPlaceLabel.text = house.topScoreUsers![4].userName
            fifthPointsLabel.text = house.topScoreUsers![4].totalPoints.description
        }
        
    }

    @IBAction func selectHouse(_ sender: UISegmentedControl) {
        setPlaceLabels(house: getHouseWithName(name: self.houses[houseSelectionControl.selectedSegmentIndex])!)
    }
    
    
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let nextViewController = segue.destination as! HouseTableViewController
        nextViewController.houseName = self.houses[houseSelectionControl.selectedSegmentIndex]
        
    }
    
    func getHouseWithName(name:String) -> House?{
        for house in DataManager.sharedManager.getHouses()!{
            if house.houseID == name{
                return house
            }
        }
        return nil
    }

}
