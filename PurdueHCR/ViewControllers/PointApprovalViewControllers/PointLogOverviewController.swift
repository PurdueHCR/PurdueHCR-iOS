//
//  PointLogOverviewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class PointLogOverviewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	@IBOutlet var backgroundView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var typeMessageField: UITextField!
	var indexPath : IndexPath?
	var approveButton : UIButton?
	var rejectButton : UIButton?
    var pointLog: PointLog?
	let radius : CGFloat = 10
	let systemGray5 = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1.0)
	// TODO: Fix this since this view is referenced from more than one location
	var preViewContr: RHPApprovalTableViewController?
	// TODO: Rename
	var mess = [MessageLog]()
	var refresher: UIRefreshControl?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		tableView.separatorColor = systemGray5
		tableView.backgroundColor = systemGray5
		let height : CGFloat = 60
		let width : CGFloat = (self.view.frame.width - 60) / 2
		let offset : CGFloat = 20
		let heightModifier = height + offset + (self.tabBarController?.tabBar.frame.height)!
		let x = 40 + width
		let y = self.view.frame.height - heightModifier
		let approveOrigin = CGPoint.init(x: x, y: y)
		let rejectOrigin = CGPoint.init(x: 20, y: y)
		let buttonSize = CGSize.init(width: width, height: height)
		
		typeMessageField.layer.cornerRadius = typeMessageField.frame.height / 2
		typeMessageField.layer.borderColor = UIColor.lightGray.cgColor
		typeMessageField.borderStyle = .none
		typeMessageField.layer.borderWidth = 1
		
		sendButton.backgroundColor = tabBarController?.tabBar.tintColor
		sendButton.tintColor = UIColor.white
		sendButton.layer.cornerRadius = sendButton.frame.height / 2
		
		// If the user is an RHP add approve/reject buttons to the view
		if (User.get(.permissionLevel) as! Int == 1) {
			if let navController = self.navigationController, navController.viewControllers.count >= 2 {
				let viewController = navController.viewControllers[navController.viewControllers.count - 2]
				// TODO: Update this implementation. Could break if title of viewcontroller changes and it probably is not efficient
				if (viewController.title! != "Submitted Points") {
					approveButton = UIButton.init(type: .custom)
					approveButton?.frame = CGRect.init(origin: approveOrigin, size: buttonSize)
					rejectButton = UIButton.init(type: .custom)
					rejectButton?.frame = CGRect.init(origin: rejectOrigin, size: buttonSize)
					
					approveButton?.setTitle("Approve", for: .normal)
					approveButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
					approveButton?.layer.cornerRadius = 10
					/*if #available(iOS 13, *) {
					approveButton?.backgroundColor = UIColor.get
					} else {
					
					}*/
					approveButton?.backgroundColor = UIColor.init(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.00)
					approveButton?.addTarget(self, action: #selector(approvePointLog), for: .touchUpInside)
					
					rejectButton?.setTitle("Reject", for: .normal)
					rejectButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
					rejectButton?.layer.cornerRadius = 10
					rejectButton?.backgroundColor = UIColor.red
					rejectButton?.addTarget(self, action: #selector(rejectPointLog), for: .touchUpInside)
					
					self.backgroundView.addSubview(approveButton!)
					self.backgroundView.addSubview(rejectButton!)
				} else {
					// TODO: Better if layout implementation so that code is not repeated twice
					bottomConstraint.constant = -60
					self.tableView.layoutIfNeeded()
				}
			}
			
		} else {
			bottomConstraint.constant = -60
			self.tableView.layoutIfNeeded()
		}
		
	
		refresher = UIRefreshControl()
		refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refresher?.addTarget(self, action: #selector(resfreshData), for: .valueChanged)
		tableView.refreshControl = refresher
		resfreshData()
		
		self.typeMessageField.delegate = self
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		DataManager.sharedManager.getMessagesForPointLog(pointLog: pointLog!, onDone: { (messageLogs:[MessageLog]) in
			self.mess = messageLogs
		})
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @objc func approvePointLog() {
        approveButton?.isEnabled = false
        //preViewContr?.displayedLogs.remove(at:index!.row)
		if (pointLog?.wasHandled == true) {
			if let pointSubmittedViewContr = (preViewContr as! PointsSubmittedViewController?) {
				pointSubmittedViewContr.updatePointLogStatus(log: pointLog!, approve: true, updating: true, indexPath: indexPath!)
			}
		} else {
			preViewContr?.updatePointLogStatus(log: pointLog!, approve: true, updating: false, indexPath: indexPath!)
		}
		
        self.navigationController?.popViewController(animated: true)
    }
	
    @objc func rejectPointLog() {
        rejectButton?.isEnabled = false
        //preViewContr?.displayedLogs.remove(at: index!.row)
		if (pointLog?.wasHandled == true) {
			if let pointSubmittedViewContr = (preViewContr as! PointsSubmittedViewController?) {
				pointSubmittedViewContr.updatePointLogStatus(log: pointLog!, approve: false, updating: true, indexPath: indexPath!)
			}
		} else {
			preViewContr?.updatePointLogStatus(log: pointLog!, approve: false, updating: false, indexPath: indexPath!)
		}
        self.navigationController?.popViewController(animated: true)
    }
	
	@objc func resfreshData(){
		DataManager.sharedManager.getMessagesForPointLog(pointLog: pointLog!, onDone: { (messageLogs:[MessageLog]) in
			// TODO: Probably a cleaner implementation of this??
			self.mess = messageLogs
			DispatchQueue.main.async { [unowned self] in
				self.tableView.reloadData()
			}
			self.tableView.refreshControl?.endRefreshing()
		})
		self.tableView.reloadData()
	}

	@IBAction func sendMessage(_ sender: Any) {
		let message = typeMessageField.text!
			if (message != "") {
			DataManager.sharedManager.addMessageToPointLog(message: message, messageType: .comment, pointID: pointLog!.logID!)
			typeMessageField.text! = ""
			resfreshData()
				
			// TODO: Fix this so it actually runs after the textfield has added the new log
			scrollToBottom()
		}
	}
	
	// MARK: - Table view data source
	
	// Todo: Does this function need to be implemented?
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return mess.count + 1 // Account for the first cell that is the point description
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		for view in cell.subviews {
			view.removeFromSuperview()
		}
		cell.backgroundColor = systemGray5
		
		if (indexPath.row == 0) {
			let pointDescriptionView = PointDescriptionView()
			pointDescriptionView.setLog(pointLog: pointLog!)
			pointDescriptionView.layer.cornerRadius = radius
			pointDescriptionView.layer.shadowColor = UIColor.darkGray.cgColor
			pointDescriptionView.layer.shadowOpacity = 0.5
			pointDescriptionView.layer.shadowOffset = CGSize.zero
			pointDescriptionView.layer.shadowRadius = 5
			cell.addSubview(pointDescriptionView)
		
			pointDescriptionView.translatesAutoresizingMaskIntoConstraints = false
			let horizontalConstraint = NSLayoutConstraint(item: pointDescriptionView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
			let verticalConstraint = NSLayoutConstraint(item: pointDescriptionView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 35)
			let widthConstraint = NSLayoutConstraint(item: pointDescriptionView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
			
			NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint])
			// TODO: Rename
			let thistest = NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal, toItem: pointDescriptionView, attribute: .height, multiplier: 1, constant: 45)
			NSLayoutConstraint.activate([thistest])
			
			
		} else {
		
			let messageView = MessageView.init()
			messageView.layer.cornerRadius = radius
			messageView.layer.shadowColor = UIColor.darkGray.cgColor
			messageView.layer.shadowOpacity = 0.5
			messageView.layer.shadowOffset = CGSize.zero
			messageView.layer.shadowRadius = 5
			messageView.setLog(messageLog: mess[indexPath.row - 1])
			messageView.sizeToFit()
			cell.addSubview(messageView)
			
			messageView.translatesAutoresizingMaskIntoConstraints = false
			let horizontalConstraint = NSLayoutConstraint(item: messageView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
			let verticalConstraint = NSLayoutConstraint(item: messageView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 35)
			let widthConstraint = NSLayoutConstraint(item: messageView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
			
			NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint])
			// TODO: Rename
			let thistest = NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal, toItem: messageView, attribute: .height, multiplier: 1, constant: 45)
			NSLayoutConstraint.activate([thistest])
			
		}
		
		return cell
	}
	
	// Support conditional editing of the table view.
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	// TODO: Update this implementation. I can't imagine it being very efficient or scalable. Plus it doesn't use constants so changing constraints elsewhere would completely throw this off
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if (User.get(.permissionLevel) as! Int == 1) {
				approveButton!.isHidden = true
				rejectButton!.isHidden = true
			}
			bottomConstraint.constant = -1 * (60 + keyboardSize.height - (self.tabBarController?.tabBar.frame.size.height)!)
			self.tableView.layoutIfNeeded()
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		if (User.get(.permissionLevel) as! Int != 1) {
			bottomConstraint.constant = -60
		} else {
			bottomConstraint.constant = -145
			approveButton!.isHidden = false
			rejectButton!.isHidden = false
		}
		
		self.tableView.layoutIfNeeded()
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		scrollToBottom()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	
	
	// TODO: This should probably be an extension to the textview
	func scrollToBottom() {
		let bottomOffset = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.bounds.size.height)
		self.tableView.setContentOffset(bottomOffset, animated: true)
	}
	
}
