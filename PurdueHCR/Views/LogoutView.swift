//
//  LogoutView.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 8/29/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit
import FirebaseAuth
import Cely

class LogoutView: UIView {

    @IBOutlet var logoutView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var policyButton: UIButton!
    @IBOutlet weak var conditionsButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    var delegate: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        //commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("LogoutView", owner: self, options: nil)
        addSubview(logoutView)
        logoutView.frame = self.bounds
        logoutView.layer.cornerRadius = DefinedValues.radius
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLabel.text = "Version " + (appVersion ?? "")
        
        let closeImage = #imageLiteral(resourceName: "SF_xmark").withRenderingMode(.alwaysTemplate)
        closeButton.setBackgroundImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.lightGray
        closeButton.setTitle("", for: .normal)
        
        configureButtonStyle(button: joinButton)
        joinButton.backgroundColor = DefinedValues.systemGray4
        
        policyButton.layer.cornerRadius = DefinedValues.radius
        conditionsButton.layer.cornerRadius = DefinedValues.radius
        reportButton.layer.cornerRadius = DefinedValues.radius
        
        
        configureButtonStyle(button: logoutButton)
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
        
        
    }
    
    func configureButtonStyle(button: UIButton) {
        button.tintColor = UIColor.white
        button.backgroundColor = DefinedValues.systemBlue
        button.layer.cornerRadius = DefinedValues.radius
    }
    
    @IBAction func closeView(_ sender: Any) {
        if (delegate!.isKind(of: HouseProfileViewController.self)) {
            let newDelegate = delegate as! HouseProfileViewController
            newDelegate.buttonAction()
        } else {
            let newDelegate = delegate as! HouseCompetitionOverviewTableViewController
            newDelegate.dismissRECLogout()
        }
    }
    
    @IBAction func join(_ sender: Any) {
        
        if let url = URL(string: "https://purduehcr.slack.com/join/shared_invite/zt-96fxky0h-dp6ceejRxF_CkPjmLROVhA#/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func openConditions(_ sender: Any) {
        if let url = URL(string: "https://purduehcr.web.app/terms-and-conditions") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func openPolicy(_ sender: Any) {
        if let url = URL(string: "https://purduehcr.web.app/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func report(_ sender: Any) {
        if let url = URL(string: "https://sites.google.com/view/hcr-points/home") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController.init(title: "Log out?", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let noAction = UIAlertAction.init(title: "No", style: .default) { (action) in
        }
        let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
            try? Auth.auth().signOut()
            Cely.logout()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        delegate?.present(alert, animated: true)
    }
    
    
}
