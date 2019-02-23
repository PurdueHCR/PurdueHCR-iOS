//
//  PointLogOverviewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class PointLogOverviewController: UIViewController {
    
    @IBOutlet var approveButton: UIButton!
    @IBOutlet var rejectButton: UIButton!
	
	var indexPath : IndexPath?
    
    var pointLog: PointLog?
    //var index: IndexPath?
    @IBOutlet var pointDescriptionView: PointDescriptionView!
	var preViewContr: RHPApprovalTableViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pointDescriptionView.setLog(pointLog: pointLog!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func approvePointLog(_ sender: Any) {
        approveButton.isEnabled = false
        //preViewContr?.displayedLogs.remove(at:index!.row)
		if (pointLog?.wasHandled == true) {
			if let pointSubmittedViewContr = (preViewContr as! PointsSubmittedViewController?) {
				pointSubmittedViewContr.updatePointLogStatus(log: pointLog!, approve: true, indexPath: indexPath!)
			}
		} else {
			preViewContr?.updatePointLogStatus(log: pointLog!, approve: true, indexPath: indexPath!)
		}
		
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func rejectPointLog(_ sender: Any) {
        rejectButton.isEnabled = false
        //preViewContr?.displayedLogs.remove(at: index!.row)
		if (pointLog?.wasHandled == true) {
			preViewContr = preViewContr as! PointsSubmittedViewController
		}
		preViewContr?.updatePointLogStatus(log: pointLog!, approve: false, indexPath: indexPath!)
        self.navigationController?.popViewController(animated: true)
    }
    

}
