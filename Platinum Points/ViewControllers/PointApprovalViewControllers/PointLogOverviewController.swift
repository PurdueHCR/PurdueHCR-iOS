//
//  PointLogOverviewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class PointLogOverviewController: UIViewController {
    var pointLog: PointLog?
    var index: IndexPath?
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
        preViewContr?.unconfirmedLogs.remove(at:index!.row)
        preViewContr?.handlePointApproval(log: pointLog!, approve: true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func rejectPointLog(_ sender: Any) {
        preViewContr?.unconfirmedLogs.remove(at: index!.row)
        preViewContr?.handlePointApproval(log: pointLog!, approve: false)
        self.navigationController?.popViewController(animated: true)
    }
    

}
