//
//  TabBarController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let permission = User.get(.permissionLevel) else{
            return
        }
        let p = permission as! Int
        var viewControllers : [UIViewController] = []
        if (p == 0){
            viewControllers.append(linkPointSubmissionViewController())
            viewControllers.append(linkProfileViewController())
        }
        else if( p == 1){
            viewControllers.append(linkPointSubmissionViewController())
            viewControllers.append(linkProfileViewController())
            viewControllers.append(linkPointApprovalViewController())
            viewControllers.append(linkQRCodeViewController())
        }
        // Do any additional setup after loading the view.
        self.setViewControllers(viewControllers, animated: false)

    }
    
    func linkPointSubmissionViewController() -> UIViewController {
        let pointSubmissionViewController = UIStoryboard(name: "PointSubmission", bundle: nil).instantiateViewController(withIdentifier: "Point_Submission_Initial") as! UINavigationController
        return pointSubmissionViewController
    }
    
    func linkProfileViewController() -> UIViewController {
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "Profile_Initial") as! UINavigationController
        return profileViewController
    }
    
    func linkPointApprovalViewController() -> UIViewController {
        let pointApprovalViewController = UIStoryboard(name: "PointApproval", bundle: nil).instantiateViewController(withIdentifier: "Point_Approval_Initial") as! UINavigationController
        pointApprovalViewController.tabBarItem = UITabBarItem(title: "Approve", image: #imageLiteral(resourceName: "check"), selectedImage: #imageLiteral(resourceName: "check"))
        return pointApprovalViewController
    }
    
    func linkQRCodeViewController() -> UIViewController {
        let qrCodeViewController = UIStoryboard(name: "QRCode", bundle: nil).instantiateViewController(withIdentifier: "QR_Code_Initial") as! UINavigationController
        qrCodeViewController.tabBarItem = UITabBarItem(title: "QR", image: #imageLiteral(resourceName: "QRCode"), selectedImage: #imageLiteral(resourceName: "QRCode"))
        return qrCodeViewController
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if(NewLaunch.newLaunch.isFirstLaunch){
//            createNewLaunchAlert()
//        }
//    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
