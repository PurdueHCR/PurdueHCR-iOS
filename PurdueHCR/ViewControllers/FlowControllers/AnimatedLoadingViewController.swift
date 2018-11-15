//
//  AnimatedLoadingViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/23/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import Cely

class AnimatedLoadingViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    let images = [#imageLiteral(resourceName: "Platinum"),#imageLiteral(resourceName: "Copper"),#imageLiteral(resourceName: "Titanium"),#imageLiteral(resourceName: "Silver"),#imageLiteral(resourceName: "Palladium")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Cely.currentLoginStatus() == .loggedIn){
            if(NewLaunch.newLaunch.isFirstLaunch){
                //createNewLaunchAlert()
            }
            finishLoadinng()

        }
        else{
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func finishLoadinng(){
        DataManager.sharedManager.initializeData(finished: {() in
            self.performSegue(withIdentifier: "doneWithInit", sender: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setImage() {
        let i = Int(arc4random_uniform(5))
        let toImage = images[i]
        self.imageView.image = toImage
    }
    
    //This will be for showing announcements
    func createNewLaunchAlert(){
        let alert = UIAlertController(title: "Are you interested in joining Development Committee?", message: "Development Committee is looking for software developers, marketers, and designers to help with the future of Purdue HCR. If you are interested in helping, checkout our Discord channel!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Take me to the Discord", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            UIApplication.shared.open(URL(string: "https://discord.gg/jptXrYG")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            self.finishLoadinng()
        }))
        alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertAction.Style.default, handler: {(action)in
            alert.dismiss(animated: true, completion: self.finishLoadinng)
            self.finishLoadinng()
        }))
        self.present(alert, animated: true, completion: nil)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
