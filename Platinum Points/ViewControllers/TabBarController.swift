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
        let p = Int(permission as! String)!
        if( p > 0){
            let viewc = self.storyboard?.instantiateViewController(withIdentifier: "RHP_Only_Approval") as! UINavigationController
            viewc.tabBarItem = UITabBarItem(title: "Approve", image: #imageLiteral(resourceName: "check"), selectedImage: #imageLiteral(resourceName: "check"))
            if let vcs = self.viewControllers {
                var newVcs : [UIViewController] = []
                for vc in vcs {
                   newVcs.append(vc)
                }
                newVcs.append(viewc)
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
