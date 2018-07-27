//
//  AnimatedLoadingViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/23/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class AnimatedLoadingViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    let images = [#imageLiteral(resourceName: "Platinum"),#imageLiteral(resourceName: "Copper"),#imageLiteral(resourceName: "Titanium"),#imageLiteral(resourceName: "Silver"),#imageLiteral(resourceName: "Palladium")]
    var i = Int(arc4random_uniform(5))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DataManager.sharedManager.initializeData(finished: {() in
            self.performSegue(withIdentifier: "doneWithInit", sender: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setImage() {
        let toImage = images[i]
        self.imageView.image = toImage
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
