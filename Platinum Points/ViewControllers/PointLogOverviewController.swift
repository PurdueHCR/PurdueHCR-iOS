//
//  PointLogOverviewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class PointLogOverviewController: UIViewController {
    @IBOutlet var residentLabel: UILabel!
    @IBOutlet var pointTypeDescriptionLabel: UILabel!
    @IBOutlet var reportTimeStampLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    var pointLog: PointLog?
    var index: IndexPath?
    var preViewContr: RHPApprovalTableViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        residentLabel.text = pointLog?.resident
        pointTypeDescriptionLabel.text = pointLog?.type.pointDescription
        reportTimeStampLabel.text = "Report Time: Noon"
        descriptionLabel.text = pointLog?.pointDescription
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func approvePointLog(_ sender: Any) {
        preViewContr?.unconfirmedLogs.remove(at:index!.row)
        preViewContr?.tableView.deleteRows(at: [index!], with: .automatic)
        preViewContr?.handlePointApproval(log: pointLog!, approve: true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func rejectPointLog(_ sender: Any) {
        preViewContr?.unconfirmedLogs.remove(at: index!.row)
        preViewContr?.tableView.deleteRows(at: [index!], with: .automatic)
        preViewContr?.handlePointApproval(log: pointLog!, approve: false)
        self.navigationController?.popViewController(animated: true)
    }
    

}
