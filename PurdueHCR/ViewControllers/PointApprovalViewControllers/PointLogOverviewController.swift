//
//  PointLogOverviewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class PointLogOverviewController: UIViewController {
    
	@IBOutlet weak var scrollView: UIScrollView!
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
		self.approveButton.layer.shadowColor = UIColor.gray.cgColor
		self.approveButton.layer.shadowRadius = 3
		self.approveButton.layer.shadowOpacity = 15
		self.approveButton.layer.shadowOffset = CGSize.init(width: 0, height: 2)
		
		self.rejectButton.layer.shadowColor = UIColor.gray.cgColor
		self.rejectButton.layer.shadowRadius = 3
		self.rejectButton.layer.shadowOpacity = 15
		self.rejectButton.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        // Do any additional setup after loading the view.
		//let plusImage = UIImage(named: "list")?.withRenderingMode(.alwaysTemplate)
		
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
				pointSubmittedViewContr.updatePointLogStatus(log: pointLog!, approve: true, updating: true, indexPath: indexPath!)
			}
		} else {
			preViewContr?.updatePointLogStatus(log: pointLog!, approve: true, updating: false, indexPath: indexPath!)
		}
		
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func rejectPointLog(_ sender: Any) {
        rejectButton.isEnabled = false
        //preViewContr?.displayedLogs.remove(at: index!.row)
		if (pointLog?.wasHandled == true) {
			if let pointSubmittedViewContr = (preViewContr as! PointsSubmittedViewController?) {
				pointSubmittedViewContr.updatePointLogStatus(log: pointLog!, approve: false, updating: true, indexPath: indexPath!)
			}
		} else {
			preViewContr?.updatePointLogStatus(log: pointLog!, approve: false, updating: false, indexPath: indexPath!)
		}
        self.navigationController?.popViewController(animated: true)
    }
    

}
