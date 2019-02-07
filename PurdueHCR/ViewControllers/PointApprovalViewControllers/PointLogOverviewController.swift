//
//  PointLogOverviewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_ButtonThemer

class PointLogOverviewController: UIViewController {
    
    @IBOutlet var approveButton: UIButton!
    @IBOutlet var rejectButton: UIButton!
    
    
    var pointLog: PointLog?
    var index: IndexPath?
    @IBOutlet var pointDescriptionView: PointDescriptionView!
    var preViewContr: RHPApprovalTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pointDescriptionView.setLog(pointLog: pointLog!)
        // Do any additional setup after loading the view.
		//let plusImage = UIImage(named: "list")?.withRenderingMode(.alwaysTemplate)
		let buttonScheme = MDCButtonScheme()
		let button = MDCFloatingButton()
		button.titleLabel?.text = "Hello World!"
		button.setBackgroundColor(UIColor.black)
		//button.setImage(plusImage, for: .normal)
		MDCFloatingActionButtonThemer.applyScheme(buttonScheme, to: button)
		button.minimumSize = CGSize(width: 64, height: 48)
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func approvePointLog(_ sender: Any) {
        approveButton.isEnabled = false
        preViewContr?.unconfirmedLogs.remove(at:index!.row)
        preViewContr?.handlePointApproval(log: pointLog!, approve: true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func rejectPointLog(_ sender: Any) {
        rejectButton.isEnabled = false
        preViewContr?.unconfirmedLogs.remove(at: index!.row)
        preViewContr?.handlePointApproval(log: pointLog!, approve: false)
        self.navigationController?.popViewController(animated: true)
    }
    

}
