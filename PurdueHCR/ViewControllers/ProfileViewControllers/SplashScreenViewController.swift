//
//  SplashScreenViewController.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 7/9/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

	@IBOutlet weak var doneButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		doneButton.backgroundColor = self.view.tintColor
		doneButton.layer.cornerRadius = 10
		doneButton.tintColor = UIColor.white
		
        // Do any additional setup after loading the view.
    }
	
	@IBAction func doneAction(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
