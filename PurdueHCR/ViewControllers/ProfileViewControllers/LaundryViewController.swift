//
//  LaundryViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 11/10/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

var filterNorth : Bool = true

class LaundryViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var machinesContainerView: LaundryCollectionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

}




class LaundryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var itemsPerRow : CGFloat = 8;
    
    let northWashers : CGFloat = 12
    let northDryers : CGFloat = 16
    let southWashers : CGFloat = 8
    let southDryers : CGFloat = 12
    
    let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    var refresher: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // More dryers per row than washers
        // Want icons same size so use this as the standard
        if (filterNorth) {
            itemsPerRow = northDryers
        } else {
            itemsPerRow = southDryers
        }
        itemsPerRow /= 2
        
        refresher = UIRefreshControl()
        refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher?.addTarget(self, action:  #selector(reloadData), for: .valueChanged)
        self.collectionView.refreshControl = refresher
    }
    
    @objc func reloadData() {
        if (filterNorth) {
            itemsPerRow = northDryers
        } else {
            itemsPerRow = southDryers
        }
        itemsPerRow /= 2
        print("items per row: ", itemsPerRow)
        self.collectionView.reloadData()
        self.collectionView.refreshControl?.endRefreshing()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // Clear the old views from the reusable cell
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        
        let column = indexPath.row % Int(itemsPerRow)
        var addWasher = false
        if (filterNorth) {
            addWasher = column < Int(itemsPerRow / 2)
        } else {
            addWasher = column >= Int(itemsPerRow / 2)
        }
        if (indexPath.section == 0 || addWasher) {
            let machineView = LaundryMachineView.init()
            machineView.layer.cornerRadius = DefinedValues.radius
            machineView.backgroundView.backgroundColor = UIColor.green
            machineView.clipsToBounds = false
            machineView.layer.masksToBounds = false
            //machineView.delegate = self
            
            machineView.contentMode = .scaleAspectFit
            if (indexPath.section == 0) {
                var machineImage = UIImage.init(imageLiteralResourceName: "Dryer").withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                machineImage = self.resizedImage(image: machineImage, for: cell.bounds.size)!
                print("machine image size ", machineImage.size)
                machineView.backgroundImage.image = machineImage

            } else {
                var machineImage = UIImage.init(imageLiteralResourceName: "Washer").withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                machineImage = self.resizedImage(image: machineImage, for: cell.bounds.size)!
                machineView.backgroundImage.image = machineImage
            }
            
            machineView.machineNumberLabel.text = "1"
            machineView.layer.borderWidth = 2.0
            machineView.layer.borderColor = UIColor.orange.cgColor
            
            cell.contentView.clipsToBounds = false
            cell.clipsToBounds = false
            
            cell.addSubview(machineView)
                        
            machineView.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: machineView, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: machineView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 0)
            let centeredVertically = NSLayoutConstraint(item: machineView, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: machineView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([horizontalConstraint, heightConstraint, widthConstraint, centeredVertically])
            
            
        }
        
        cell.backgroundColor = UIColor.clear
        
        
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Dryer section
        if (filterNorth) {
            return Int(northDryers)
        } else {
            return Int(southDryers)
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
        return 0
    }
    
    func resizedImage(image: UIImage, for size: CGSize) -> UIImage? {
        let smallerSize = CGSize(width: size.width - 10, height: size.height - 10)
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
