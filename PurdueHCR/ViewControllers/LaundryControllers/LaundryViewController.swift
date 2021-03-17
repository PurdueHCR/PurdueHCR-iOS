//
//  LaundryViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 11/10/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit
import PopupKit

var filterNorth : Bool = true

struct defaultsKeys {
    static let filterBuilding = "filter_building"
    static let pinnedNorthMachines = "pinned_north_machines"
    static let pinnedSouthMachines = "pinned_south_machines"
}

class MachineStatus {
    
    static let available = UIColor.green
    static let inUse = UIColor.systemRed
    static let finishing = UIColor.systemOrange
    static let finished = UIColor.systemBlue.withAlphaComponent(0.75)
    static let outOfOrder = UIColor.darkGray
    
}

enum MachineType {
    case washer
    case dryer
}

class Machine {
    
    var status : UIColor?
    var number : Int?
    var endTime : Date?
    var machineType : MachineType?
    
    
    init(machineType: MachineType, number: Int, status: UIColor, endTime: Date) {
        self.machineType = machineType
        self.number = number
        self.status = status
        self.endTime = endTime
    }
    
    func getTimeRemainingString() -> String {
        // I think the API should calculate the time the machine ends and then pass that to us and then we should display that to the user
        
        if (status == MachineStatus.finished || status == MachineStatus.available || status == MachineStatus.outOfOrder) {
            return "--:--"
        }
        return "5:34"
    }
    
    func getName() -> String {
        var name = String(self.number!)
        if (machineType == MachineType.dryer) {
            name = "Dryer " + name
        } else {
            name = "Washer " + name
        }
        return name
    }
    
}

class LaundryViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var removeName: UIView!
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var machinesContainerView: LaundryCollectionViewController!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    
    var northDryers : [Machine] = []
    var northWashers : [Machine] = []
    var southDryers : [Machine] = []
    var southWashers : [Machine] = []
        
    var northPinnedMachines : [Machine] = []
    var southPinnedMachines : [Machine] = []
    
    var p : PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (filterNorth) {
            buildingLabel.text = "Honors North"
        } else {
            buildingLabel.text = "Honors South"
        }
        
        // Set up list of machines for the table view
        northDryers = machinesContainerView.northDryers
        northWashers = machinesContainerView.northWashers
        southDryers = machinesContainerView.southDryers
        southWashers  = machinesContainerView.southWashers
        
        northDryers.sort(by: {$0.number! < $1.number! })
        northWashers.sort(by: {$0.number! < $1.number! })
        southDryers.sort(by: {$0.number! < $1.number! })
        southWashers.sort(by: {$0.number! < $1.number! })
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.removeName.backgroundColor = UIColor.groupTableViewBackground
        scrollView.backgroundColor = UIColor.groupTableViewBackground
        
        let defaults = UserDefaults.standard
        if (filterNorth) {
            if let pinned = defaults.array(forKey: defaultsKeys.pinnedNorthMachines) {
                removePinnedMachineRows(pinnedMachineNames: pinned as! [String])
            }
        } else {
            if let pinned = defaults.array(forKey: defaultsKeys.pinnedSouthMachines) {
                removePinnedMachineRows(pinnedMachineNames: pinned as! [String])
            }
        }
        
    }
    
    // Remove the pinned machines from the standard row when view first loads
    func removePinnedMachineRows(pinnedMachineNames : [String]) {

        // Update machines for view we are switching to
        // North Machines
        for machine in pinnedMachineNames {
            if (machine.contains("Dryer")) {
                // North Dryers
                for (index, dryer) in northDryers.enumerated() {
                    if (dryer.getName() == machine) {
                        northPinnedMachines.append(dryer)
                        northDryers.remove(at: index)
                    }
                }
            } else {
                // North Washers
                for (index, washer) in northWashers.enumerated() {
                    if (washer.getName() == machine) {
                        northPinnedMachines.append(washer)
                        northWashers.remove(at: index)
                    }
                }
            }
        }
        
        // South Machines
        for machine in pinnedMachineNames {
            if (machine.contains("Dryer")) {
                // South Dryers
                for (index, dryer) in southDryers.enumerated() {
                    if (dryer.getName() == machine) {
                        southPinnedMachines.append(dryer)
                        southDryers.remove(at: index)
                    }
                }
            } else {
                // South Washers
                for (index, washer) in southWashers.enumerated() {
                    if (washer.getName() == machine) {
                        southPinnedMachines.append(washer)
                        southWashers.remove(at: index)
                    }
                }
            }
        }

        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        // Update table view height
        let tableHeight = tableView.contentSize.height
        tableHeightConstraint.constant = tableHeight + 10
        
        machinesContainerView.delegate = self
        machinesContainerView.collectionView.layer.cornerRadius = DefinedValues.radius
        
        // Update the height constraint now that the view has loaded
        machinesContainerView.updateViewHeight()
    }
    
    
    /// Display the North/South building selection dropdown
    @IBAction func filter(_ sender: Any) {
        let storyboard = self.storyboard
        
        let menuViewController = storyboard?.instantiateViewController(withIdentifier: "filter_view")
            menuViewController?.modalPresentationStyle = .popover
            menuViewController?.preferredContentSize = CGSize(width: 200, height: 87)
        
        if let menuPresentationController = menuViewController?.popoverPresentationController{
            menuPresentationController.permittedArrowDirections = .up
            menuPresentationController.sourceView = self.view
            let frame = (filterButton.value(forKey: "view") as! UIView).superview!.frame
            // Shift the location the popup displays to under the button instead of at the top of the button
            let modifiedFrame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: frame.height)
            menuPresentationController.sourceRect = modifiedFrame
            menuPresentationController.delegate = self
            if let popoverController = menuViewController {
                let contr = menuViewController as! LaundryBuildingTableViewController
                contr.machinesView = machinesContainerView
                contr.delegate = self
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    
    //UIPopoverPresentationControllerDelegate inherits from UIAdaptivePresentationControllerDelegate, we will use this method to define the presentation style for popover presentation controller
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    // Store the collection view once it has been added to the current view via a segue to the embedded view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "show_collection") {
            guard let destinationVC = segue.destination as? LaundryCollectionViewController else { return }
            machinesContainerView = destinationVC
        }
    }
    
    func hasPinnedMachines() -> Bool {
        return (northPinnedMachines.count > 0 && filterNorth) || (southPinnedMachines.count > 0 && !filterNorth)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if (hasPinnedMachines()) {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0 && hasPinnedMachines()) {
            return "Pinned Machines"
        }
        else if (section == 1 && hasPinnedMachines() || section == 0 && !hasPinnedMachines()) {
            return "Dryers"
        } else {
            return "Washers"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0 && hasPinnedMachines()) {
            if (filterNorth) {
                return northPinnedMachines.count
            } else {
                return southPinnedMachines.count
            }
        }
        else if (section == 1 && hasPinnedMachines() || section == 0 && !hasPinnedMachines()) {
            // Dryers
            if (filterNorth) {
                return northDryers.count
            } else {
                return southDryers.count
            }
        } else {
            // Washers
            if (filterNorth) {
                return northWashers.count
            } else {
                return southWashers.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : MachineTableCell
        cell = tableView.dequeueReusableCell(withIdentifier: "table_cell", for: indexPath) as! MachineTableCell
        
        if (indexPath.section == 0 && hasPinnedMachines()) {
            // Pinned Machines
            if (filterNorth) {
                cell.nameLabel.text = northPinnedMachines[indexPath.row].getName()
            } else {
                cell.nameLabel.text = southPinnedMachines[indexPath.row].getName()
            }
        }
        else if (indexPath.section == 1 && hasPinnedMachines() || indexPath.section == 0 && !hasPinnedMachines()) {
            // Dryers
            if (filterNorth) {
                cell.nameLabel.text = northDryers[indexPath.row].getName()
            } else {
                cell.nameLabel.text = southDryers[indexPath.row].getName()
            }
        } else {
            // Washers
            if (filterNorth) {
                cell.nameLabel.text = northWashers[indexPath.row].getName()
            } else {
                cell.nameLabel.text = southWashers[indexPath.row].getName()
            }
        }
        
        cell.timeRemainingLabel.text = "5:34"
        cell.statusView.backgroundColor = MachineStatus.available.withAlphaComponent(1.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions : [UIContextualAction] = []
        if (indexPath.section == 0 && hasPinnedMachines()) {
            // Remove pin
            let contextItem = UIContextualAction(style: .normal, title: "Remove Pin") { (action, view, boolValue) in
                let defaults = UserDefaults.standard
                if (filterNorth) {
                    let removedMachine = self.northPinnedMachines[indexPath.row]
                    self.northPinnedMachines.remove(at: indexPath.row)
                    var pinnedMachineNames : [String] = []
                    for machine in self.northPinnedMachines {
                        pinnedMachineNames.append(machine.getName())
                    }
                    defaults.set(pinnedMachineNames, forKey: defaultsKeys.pinnedNorthMachines)
                    if (removedMachine.machineType == MachineType.dryer) {
                        self.northDryers.append(removedMachine)
                        self.northDryers.sort(by: {$0.number! < $1.number! })
                    } else {
                        self.northWashers.append(removedMachine)
                        self.northWashers.sort(by: {$0.number! < $1.number! })
                    }
                } else {
                    let removedMachine = self.southPinnedMachines[indexPath.row]
                    self.southPinnedMachines.remove(at: indexPath.row)
                    var pinnedMachineNames : [String] = []
                    for machine in self.southPinnedMachines {
                        pinnedMachineNames.append(machine.getName())
                    }
                    defaults.set(pinnedMachineNames, forKey: defaultsKeys.pinnedSouthMachines)
                    if (removedMachine.machineType == MachineType.dryer) {
                        self.southDryers.append(removedMachine)
                        self.southDryers.sort(by: {$0.number! < $1.number! })
                    } else {
                        self.southWashers.append(removedMachine)
                        self.southWashers.sort(by: {$0.number! < $1.number! })
                    }
                }
                tableView.reloadData()
            }
            contextItem.image = #imageLiteral(resourceName: "SF_pin_fill")
            contextItem.backgroundColor = UIColor.systemBlue
            actions.append(contextItem)
        } else {
            // Pin machine
            let contextItem = UIContextualAction(style: .normal, title: "Pin") {  (contextualAction, view, boolValue) in

                if ((indexPath.section == 1 && self.hasPinnedMachines()) || (indexPath.section == 0 &&
                                                                                !self.hasPinnedMachines())) {
                    // Dryers
                    if (filterNorth) {
                        self.northPinnedMachines.append(self.northDryers[indexPath.row])
                        self.northDryers.remove(at: indexPath.row)
                    } else {
                        self.southPinnedMachines.append(self.southDryers[indexPath.row])
                        self.southDryers.remove(at: indexPath.row)
                    }
                }
                else if ((indexPath.section == 2 && self.hasPinnedMachines()) || (indexPath.section == 1 && !self.hasPinnedMachines())) {
                    // Washers
                    if (filterNorth) {
                        self.northPinnedMachines.append(self.northWashers[indexPath.row])
                        self.northWashers.remove(at: indexPath.row)
                    } else {
                        self.southPinnedMachines.append(self.southWashers[indexPath.row])
                        self.southWashers.remove(at: indexPath.row)
                    }
                }
                
                self.tableView.reloadData()
                
                let defaults = UserDefaults.standard
                var pinnedMachineNames : [String] = []
                if (filterNorth) {
                    for machine in self.northPinnedMachines {
                        pinnedMachineNames.append(machine.getName())
                    }
                    defaults.set(pinnedMachineNames, forKey: defaultsKeys.pinnedNorthMachines)
                } else {
                    for machine in self.southPinnedMachines {
                        pinnedMachineNames.append(machine.getName())
                    }
                    defaults.set(pinnedMachineNames, forKey: defaultsKeys.pinnedSouthMachines)
                }
            }
            contextItem.backgroundColor = UIColor.systemBlue
            contextItem.image = #imageLiteral(resourceName: "SF_pin")
            actions.append(contextItem)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: actions)

        return swipeActions
    }
    
    // Display color information
    @IBAction func infoButtonAction(_ sender: Any) {
       
        let width : Int = Int(self.removeName.frame.width - 20)
        let height = 205
        
        let contentView = MachineInfoView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        contentView.delegate = self
        p = PopupView(contentView: contentView)
        p?.showType = .slideInFromBottom
        p?.maskType = .dimmed
        p?.dismissType = .slideOutToBottom
        
        let xPos = self.view.frame.width / 2
        let yPos = self.view.frame.height / 2
        let location = CGPoint(x: xPos, y: yPos)
        p?.show(at: location, in: (self.tabBarController?.view)!)
    }
    
    func dismissMachineInfoPopup() {
        p?.dismiss(animated: true)
    }
    
}




class LaundryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    var itemsPerRow : CGFloat = 8;
    
    let numberOfNorthWashers : CGFloat = 12
    let numberOfNorthDryers : CGFloat = 16
    let numberOfSouthWashers : CGFloat = 8
    let numberOfSouthDryers : CGFloat = 12
    
    let northDryerNumbers = [15, 13, 11, 9, 7, 5, 3, 1, 16, 14, 12, 10, 8, 6, 4, 2]
    let northWasherNumbers = [27, 28, 29, 30, 31, 32, 21, 22, 23, 24, 25, 26]
    let southDryerNumbers = [9, 11, 13, 15, 17, 19, 10, 12, 14, 16, 18, 20]
    let southWasherNumbers = [8, 7, 6, 5, 1, 2, 3, 4]
    
    var northDryers : [Machine] = []
    var northWashers : [Machine] = []
    var southDryers : [Machine] = []
    var southWashers : [Machine] = []
    
    
    var resizedDryerImage : UIImage?
    var resizedWasherImage : UIImage?
    
    var refresher: UIRefreshControl?
    var delegate: LaundryViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for number in northDryerNumbers {
            northDryers.append(Machine(machineType: .dryer, number: number, status: MachineStatus.available, endTime: Date()))
        }
        for number in northWasherNumbers {
            northWashers.append(Machine(machineType: .washer, number: number, status: MachineStatus.available, endTime: Date()))
        }
        for number in southDryerNumbers {
            southDryers.append(Machine(machineType: .dryer, number: number, status: MachineStatus.available, endTime: Date()))
        }
        for number in southWasherNumbers {
            southWashers.append(Machine(machineType: .washer, number: number, status: MachineStatus.available, endTime: Date()))
        }
        
        // Get user preference for building from the dictionary if it exists
        let defaults = UserDefaults.standard
        if let filterBuilding = defaults.string(forKey: defaultsKeys.filterBuilding) {
            if (filterBuilding == "north") {
                filterNorth = true
            }
            else {
                filterNorth = false
            }
            
        } else {
            defaults.set("north", forKey: defaultsKeys.filterBuilding)
            filterNorth = true
        }
        
        // More dryers per row than washers
        // Want icons same size so use this as the standard
        if (filterNorth) {
            itemsPerRow = numberOfNorthDryers
        } else {
            itemsPerRow = numberOfSouthDryers
        }
        itemsPerRow /= 2
        
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action:  #selector(reloadData), for: .valueChanged)
        self.collectionView.refreshControl = refresher
        
    }
    
    @objc func reloadData() {
        if (filterNorth) {
            itemsPerRow = numberOfNorthDryers
            delegate?.buildingLabel.text = "Honors North"
        } else {
            itemsPerRow = numberOfSouthDryers
            delegate?.buildingLabel.text = "Honors South"
        }
        itemsPerRow /= 2
        
        // We do this calculation here before updating the cell images otherwise it would use the old cell size values
        let paddingSpace = sectionInsets.left * (itemsPerRow)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        updateCellImages(cellWidth: widthPerItem)
        self.collectionView.reloadData()
        self.collectionView.refreshControl?.endRefreshing()
        
        updateViewHeight()
        
        delegate?.tableView.reloadData()
    }
    
    
    /// Create the resized version of images to fit in the cells
    /// - Parameter cellWidth: width of the cell
    func updateCellImages(cellWidth: CGFloat) {
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        resizedDryerImage = resizedImageAspect(image: #imageLiteral(resourceName: "Dryer"), for: cellSize)
        resizedWasherImage = resizedImageAspect(image: #imageLiteral(resourceName: "Washer"), for: cellSize)
    }
    
    /// Update the height constraint of the collection view
    func updateViewHeight() {
        let collectionHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        delegate?.collectionHeightConstraint.constant = collectionHeight + 10
        delegate?.view.setNeedsLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if (resizedDryerImage == nil || resizedWasherImage == nil) {
            // Call this only once since resizing images is computationally expensive
            // This is also called by other functions when the view updates
            
            // We do this calculation here before updating the cell images otherwise it would use the old cell size values
            let paddingSpace = sectionInsets.left * (itemsPerRow)
            let availableWidth = collectionView.bounds.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            updateCellImages(cellWidth: widthPerItem)
        }
        
        // Clear the old views from the reusable cell
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        
        let column = indexPath.row % Int(itemsPerRow)
        var addMachine = false
        if (filterNorth) {
            addMachine = column < Int(itemsPerRow / 2)
        } else {
            addMachine = column >= Int(itemsPerRow / 2) - 1
        }
        if (indexPath.section == 0 || addMachine) {
            let machineView = LaundryMachineView()
            machineView.layer.cornerRadius = 5
            machineView.clipsToBounds = true
            machineView.layer.masksToBounds = true
            //machineView.delegate = self
            
            cell.contentView.clipsToBounds = false
            cell.clipsToBounds = false
            
            cell.addSubview(machineView)
                        
            machineView.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: machineView, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: machineView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 0)
            let centeredVertically = NSLayoutConstraint(item: machineView, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: machineView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1, constant: 0)
            
            let horizontalConstraint1 = NSLayoutConstraint(item: machineView.backgroundView!, attribute: .left, relatedBy: .equal, toItem: machineView, attribute: .left, multiplier: 1, constant: 0)
            let heightConstraint1 = NSLayoutConstraint(item: machineView.backgroundView!, attribute: .top, relatedBy: .equal, toItem: machineView, attribute: .top, multiplier: 1, constant: 0)
            let centeredVertically1 = NSLayoutConstraint(item: machineView.backgroundView!, attribute: .right, relatedBy: .equal, toItem: machineView, attribute: .right, multiplier: 1, constant: 0)
            let widthConstraint1 = NSLayoutConstraint(item: machineView.backgroundView!, attribute: .bottom, relatedBy: .equal, toItem: machineView, attribute: .bottom, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([horizontalConstraint, heightConstraint, widthConstraint, centeredVertically])
            NSLayoutConstraint.activate([horizontalConstraint1, heightConstraint1, widthConstraint1, centeredVertically1])
            
            //print(cell.bounds.size)
            //print(machineView.backgroundView.bounds.size)
            
            // Add images to the cells
            if (indexPath.section == 0) {
                // Dryer section
                machineView.backgroundImage.image = resizedDryerImage
            } else {
                // Washer section
                updateCellImages(cellWidth: cell.bounds.width)
                machineView.backgroundImage.image = resizedWasherImage
            }
            
            //print(machineView.backgroundView.bounds.size)
            //print(machineView.backgroundImage.bounds.size)
            
            // Add the machine number
            if (indexPath.section == 0) {
                // Dryers
                if (filterNorth) {
                    machineView.machineNumberLabel.text = northDryers[indexPath.row].number?.description
                } else {
                    machineView.machineNumberLabel.text = southDryers[indexPath.row].number?.description
                }
            } else {
                // Washers
                if (filterNorth) {
                    machineView.machineNumberLabel.text = northWashers[indexPath.row].number?.description
                } else {
                    // Adjust for the number of empty blocks before the washers on the right
                    var subtractNum = 2
                    if (indexPath.row > Int(itemsPerRow)) {
                        subtractNum = 4
                    }
                    machineView.machineNumberLabel.text = southWashers[indexPath.row - subtractNum].number?.description
                }
                
            }
            
            // Todo: Generate these machines after retrieval from API
            let testMachine = Machine(machineType: .dryer, number: 15, status: MachineStatus.finished, endTime: Date())
            
            if (testMachine.status == MachineStatus.outOfOrder) {
                machineView.backgroundView.backgroundColor = UIColor.darkGray
            }
            
            machineView.timeRemainingLabel.text = testMachine.getTimeRemainingString()
            machineView.statusColorView.backgroundColor = testMachine.status
        }
        
        //cell.backgroundColor = UIColor.blue
        
        return cell
    }
    
    // Two sections: one for dryers and one for washers
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // More dryers than washers
        // For even icon sizes, use the same number of dryers per row for washers per row
        if (filterNorth) {
            return Int(numberOfNorthDryers)
        } else {
            return Int(numberOfSouthDryers)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let height = (16) * 2 + (widthPerItem - 4)
        
        return CGSize(width: widthPerItem, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    /// Resize an image for the cell
    /// Note: The value 21 reflects the constraints in LaundryMachine.xib. If these constraints change, this value must be updated
    ///       I'm not entirely happy with this implementation but due to the complex nature of image resizing in Swift, this was
    ///       the best way I could figure to do this
    /// - Parameters:
    ///   - image: image to resize
    ///   - size: new size
    /// - Returns: resized image
    func resizedImageAspect(image: UIImage, for size: CGSize) -> UIImage? {
        let length = size.width - 4
        let smallerSize = CGSize(width: length, height: length)
        let renderer = UIGraphicsImageRenderer(size: smallerSize)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: smallerSize))
        }
    }
}




class LaundryBuildingTableViewController: UITableViewController {
    
    var machinesView : LaundryCollectionViewController?
    var delegate : LaundryViewController?

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "north_south_cell", for: indexPath)
        
        if (filterNorth && indexPath.row == 0) {
            cell.accessoryType = .checkmark
        }
        else if (!filterNorth && indexPath.row == 1) {
            cell.accessoryType = .checkmark
        }
        
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Honors North"
        } else {
            cell.textLabel?.text = "Honors South"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        if (indexPath.row == 0 && !filterNorth) {
            // Selected north
            filterNorth = true
            defaults.set("north", forKey: defaultsKeys.filterBuilding)
            tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.accessoryType = .none
        }
        else if (indexPath.row == 1 && filterNorth){
            // Selected south
            filterNorth = false
            defaults.set("south", forKey: defaultsKeys.filterBuilding)
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.accessoryType = .none
        }
        
        // Reload collection and table views
        machinesView?.reloadData()
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

}


/// Washer/Dryer machine cell for table view
class MachineTableCell: UITableViewCell {
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
}
