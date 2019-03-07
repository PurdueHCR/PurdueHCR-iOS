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
	
	var indexPath : IndexPath?
	var approveButton : UIButton?
	var rejectButton : UIButton?
    
    var pointLog: PointLog?
    //var index: IndexPath?
    @IBOutlet var pointDescriptionView: PointDescriptionView!
	var preViewContr: RHPApprovalTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let radius : CGFloat = 10
		
		pointDescriptionView.setLog(pointLog: pointLog!)
		pointDescriptionView.layer.cornerRadius = radius
		let height : CGFloat = 80
		let width : CGFloat = 80
		let offset : CGFloat = 20
		let heightModifier = height + offset + (self.tabBarController?.tabBar.frame.height)!
		let x = self.view.frame.width - height - offset
		let y = self.view.frame.height - heightModifier
		let approveOrigin = CGPoint.init(x: x, y: y)
		let rejectOrigin = CGPoint.init(x: 20, y: y)
		let buttonSize = CGSize.init(width: width, height: height)
		
		approveButton = UIButton.init(type: .custom)
		approveButton?.frame = CGRect.init(origin: approveOrigin, size: buttonSize)
		rejectButton = UIButton.init(type: .custom)
		rejectButton?.frame = CGRect.init(origin: rejectOrigin, size: buttonSize)
		
		approveButton?.setImage(#imageLiteral(resourceName: "approve"), for: .normal)
		approveButton?.layer.cornerRadius = radius
		approveButton?.backgroundColor = UIColor.green
		approveButton?.layer.shadowColor = UIColor.gray.cgColor
		approveButton?.layer.shadowRadius = 3
		approveButton?.layer.shadowOpacity = 15
		approveButton?.layer.shadowOffset = CGSize.init(width: 0, height: 2)
		approveButton?.addTarget(self, action: #selector(approvePointLog), for: .touchUpInside)
		
		rejectButton?.setImage(#imageLiteral(resourceName: "reject"), for: .normal)
		rejectButton?.layer.cornerRadius = radius
		rejectButton?.backgroundColor = UIColor.red
		rejectButton?.layer.shadowColor = UIColor.gray.cgColor
		rejectButton?.layer.shadowRadius = 3
		rejectButton?.layer.shadowOpacity = 15
		rejectButton?.layer.shadowOffset = CGSize.init(width: 0, height: 2)
		rejectButton?.addTarget(self, action: #selector(rejectPointLog), for: .touchUpInside)
		
		self.view.addSubview(approveButton!)
		self.view.addSubview(rejectButton!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @objc func approvePointLog() {
        approveButton?.isEnabled = false
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
	
    @objc func rejectPointLog() {
        rejectButton?.isEnabled = false
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
