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
        if( p > 0){
            let rhpView = self.storyboard?.instantiateViewController(withIdentifier: "RHP_Only_Approval") as! UINavigationController
            rhpView.tabBarItem = UITabBarItem(title: "Approve", image: #imageLiteral(resourceName: "check"), selectedImage: #imageLiteral(resourceName: "check"))
            let qrView = self.storyboard?.instantiateViewController(withIdentifier: "QR_Code") as! UINavigationController
            qrView.tabBarItem = UITabBarItem(title: "QR", image: #imageLiteral(resourceName: "QRCode"), selectedImage: #imageLiteral(resourceName: "QRCode"))
            if let vcs = self.viewControllers {
                var newVcs : [UIViewController] = []
                for vc in vcs {
                   newVcs.append(vc)
                }
                newVcs.append(rhpView)
                newVcs.append(qrView)
                self.setViewControllers(newVcs, animated: false)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
