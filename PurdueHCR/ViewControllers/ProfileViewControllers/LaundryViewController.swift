//
//  LaundryViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 11/10/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

var filterNorth : Bool = true

class LaundryViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var machinesContainerView: LaundryCollectionViewController!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var northDryers : [Int]?
    var northWashers : [Int]?
    var southDryers : [Int]?
    var southWashers : [Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        machinesContainerView.delegate = self
        machinesContainerView.collectionView.layer.cornerRadius = DefinedValues.radius
        
        if (filterNorth) {
            buildingLabel.text = "Honors North"
        } else {
            buildingLabel.text = "Honors South"
        }
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
    }
    
    override func viewDidLayoutSubviews() {
        // Update the height constraint now that the view has loaded
        machinesContainerView.updateViewHeight()
        northDryers = machinesContainerView.northDryers
        northWashers = machinesContainerView.northWashers
        southDryers = machinesContainerView.southDryers
        southWashers  = machinesContainerView.southWashers
        northDryers?.sort()
        northWashers?.sort()
        southDryers?.sort()
        southWashers?.sort()
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
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    
    //UIPopoverPresentationControllerDelegate inherits from UIAdaptivePresentationControllerDelegate, we will use this method to define the presentation style for popover presentation controller
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //UIPopoverPresentationControllerDelegate
//    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//    }
    
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Dryers"
        } else {
            return "Washers"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            // Dryers
            if (filterNorth) {
                return Int(machinesContainerView.numberOfNorthDryers)
            } else {
                return Int(machinesContainerView.numberOfSouthDryers)
            }
        } else {
            // Washers
            if (filterNorth) {
                return Int(machinesContainerView.numberOfNorthWashers)
            } else {
                return Int(machinesContainerView.numberOfSouthWashers)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "table_cell", for: indexPath)
        
        if (indexPath.section == 0) {
            // Dryers
            if (filterNorth) {
                cell.textLabel?.text = "Dryer " + String(northDryers![indexPath.row])
            } else {
                cell.textLabel?.text = "Dryer " + String(southDryers![indexPath.row])
            }
        } else {
            // Washers
            if (filterNorth) {
                cell.textLabel?.text = "Washer " + String(northWashers![indexPath.row])
            } else {
                cell.textLabel?.text = "Washer " + String(southWashers![indexPath.row])
            }
        }
        
        cell.detailTextLabel?.text = "5:34"
        
        return cell
    }
    

}




class LaundryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var itemsPerRow : CGFloat = 8;
    
    let numberOfNorthWashers : CGFloat = 12
    let numberOfNorthDryers : CGFloat = 16
    let numberOfSouthWashers : CGFloat = 8
    let numberOfSouthDryers : CGFloat = 12
    
    let northDryers = [15, 13, 11, 9, 7, 5, 3, 1, 16, 14, 12, 10, 8, 6, 4, 2]
    let northWashers = [27, 28, 29, 30, 31, 32, 21, 22, 23, 24, 25, 26]
    let southDryers = [9, 11, 13, 15, 17, 19, 10, 12, 14, 16, 18, 20]
    let southWashers = [8, 7, 6, 5, 1, 2, 3, 4]
    
    let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    var resizedDryerImage : UIImage?
    var resizedWasherImage : UIImage?
    
    var refresher: UIRefreshControl?
    var delegate: LaundryViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        delegate?.heightConstraint.constant = height + 10
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
            addMachine = column >= Int(itemsPerRow / 2)
        }
        if (indexPath.section == 0 || addMachine) {
            let machineView = LaundryMachineView()
            machineView.layer.cornerRadius = DefinedValues.radius
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
            
            print(cell.bounds.size)
            print(machineView.backgroundView.bounds.size)
            
            // Add images to the cells
            if (indexPath.section == 0) {
                // Dryer section
                machineView.backgroundImage.image = resizedDryerImage
            } else {
                // Washer section
                updateCellImages(cellWidth: cell.bounds.width)
                machineView.backgroundImage.image = resizedWasherImage
            }
            print(machineView.backgroundView.bounds.size)
            print(machineView.backgroundImage.bounds.size)
            
            // Add the machine number
            if (indexPath.section == 0) {
                // Dryers
                if (filterNorth) {
                    machineView.machineNumberLabel.text = String(northDryers[indexPath.row])
                } else {
                    machineView.machineNumberLabel.text = String(southDryers[indexPath.row])
                }
            } else {
                // Washers
                if (filterNorth) {
                    machineView.machineNumberLabel.text = String(northWashers[indexPath.row])
                } else {
                    var subtractNum = 3
                    if (indexPath.row > Int(itemsPerRow)) {
                        subtractNum = 6
                    }
                    machineView.machineNumberLabel.text = String(southWashers[indexPath.row - subtractNum])
                }
                
            }
            
            
            machineView.timeRemainingLabel.text = "5:34"
        }
        
        cell.backgroundColor = UIColor.blue
        
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

        return CGSize(width: widthPerItem, height: widthPerItem)
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
        let length = size.width - 21
        let smallerSize = CGSize(width: length, height: length)
        let renderer = UIGraphicsImageRenderer(size: smallerSize)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: smallerSize))
        }
    }
}




class LaundryBuildingTableViewController: UITableViewController {
    
    var machinesView : LaundryCollectionViewController?

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
        if (indexPath.row == 0) {
            // Selected north
            filterNorth = true
            tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.accessoryType = .none
        } else {
            // Selected south
            filterNorth = false
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.accessoryType = .none
        }
        machinesView?.reloadData()
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

}
