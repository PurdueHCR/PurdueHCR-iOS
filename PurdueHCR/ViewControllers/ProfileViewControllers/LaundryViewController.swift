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
    @IBOutlet weak var machinesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /// Display the North/South building selection dropdown
    @IBAction func filter(_ sender: Any) {
        let storyboard = self.storyboard
        
        let menuViewController = storyboard?.instantiateViewController(withIdentifier: "filter_view")
            menuViewController?.modalPresentationStyle = .popover
            menuViewController?.preferredContentSize = CGSize(width: 200, height: 75)
        
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
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        machinesContainerView.setNeedsLayout()
    }
     
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    

}




class LaundryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var itemsPerRow : CGFloat = 8;
    
    let northWashers : CGFloat = 12
    let northDryers : CGFloat = 16
    let southWashers : CGFloat = 8
    let southDryers : CGFloat = 12
    
    let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
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
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
       
        // Todo: Add refresher and make sure cells aren't recreated, only their data
        
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
            machineView.backgroundColor = UIColor.white
            machineView.clipsToBounds = false
            machineView.layer.masksToBounds = false
            //machineView.delegate = self
            cell.contentView.clipsToBounds = false
            cell.clipsToBounds = false
            cell.addSubview(machineView)
            
            machineView.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: machineView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: machineView, attribute: .height, relatedBy: .equal, toItem: cell, attribute: .height, multiplier: 1, constant: 0)
            let centeredVertically = NSLayoutConstraint(item: machineView, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 3)
            let widthConstraint = NSLayoutConstraint(item: machineView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, centeredVertically])
        }
        
        
        cell.backgroundColor = UIColor.blue
        
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

    
    // MARK: - Collection View Flow Layout Delegate
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
    
}




class LaundryBuildingTableViewController: UITableViewController {
    
    var machinesView : UIView?

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            // Selected north
            filterNorth = true
        } else {
            // Selected south
            filterNorth = false
        }
        machinesView?.setNeedsDisplay()
        self.dismiss(animated: true, completion: nil)
    }

}
