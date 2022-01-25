//
//  PointLogOverviewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/21/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit
import Firebase

class PointLogOverviewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CustomViewDelegate {
	
	@IBOutlet var backgroundView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var typeMessageField: UITextField!
    @IBOutlet weak var sendActivityIndicator: UIActivityIndicatorView!
    
    var indexPath : IndexPath?
	var approveButton : UIButton?
	var rejectButton : UIButton?
    var pointLog: PointLog?
	let radius : CGFloat = 10
	
	var preViewContr: UITableViewController?
	var messageLogs = [MessageLog]()
	var refresher: UIRefreshControl?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.sendActivityIndicator.stopAnimating()
        self.sendActivityIndicator.isHidden = true
        
		refresher = UIRefreshControl()
		refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refresher?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
		tableView.refreshControl = refresher
		//refreshData()
        
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		tableView.separatorColor = DefinedValues.systemGray5
		tableView.backgroundColor = DefinedValues.systemGray5
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
		
		let isRHP : Bool = User.get(.permissionLevel) as! Int == 1
		// If the user is an RHP add approve/reject buttons to the view
		if (isRHP) {
            
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
			approveButton?.backgroundColor = DefinedValues.systemGreen
			approveButton?.addTarget(self, action: #selector(approvePointLog), for: .touchUpInside)
			
			rejectButton?.setTitle("Reject", for: .normal)
			rejectButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
			rejectButton?.layer.cornerRadius = 10
			rejectButton?.backgroundColor = DefinedValues.systemRed
			rejectButton?.addTarget(self, action: #selector(rejectPointLog), for: .touchUpInside)
			
			self.backgroundView.addSubview(approveButton!)
			self.backgroundView.addSubview(rejectButton!)
		} else {
			bottomConstraint.constant = -60
			self.tableView.layoutIfNeeded()
		}
		
		self.typeMessageField.delegate = self
		
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
        self.refreshData()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @objc func approvePointLog() {
        updatePointLog(approve: true)
    }
    
    @objc func rejectPointLog() {
        updatePointLog(approve: false)
    }
	
    @objc func updatePointLog(approve: Bool) {
        rejectButton?.isEnabled = false
        approveButton?.isEnabled = false
        /*
            Previous view controllers could be PointsSubmittedViewController,
            RHPApproveTableViewController, UserPointsTableViewController, or
            NotificationsTableViewController
         */
        var message = ""
        if (!approve) {
            message = typeMessageField.text!
            if (message == "") {
                self.notify(title: "Error", subtitle: "You must type a message to reject a point log", style: .danger)
                rejectButton?.isEnabled = true
                approveButton?.isEnabled = true
                return
            }
            
        }
        
		if (pointLog?.wasHandled == true) {
            if (preViewContr is HousePointsHistoryViewController) {
                if let pointSubmittedViewContr = (preViewContr as! HousePointsHistoryViewController?) {
                    pointSubmittedViewContr.updatePointLogStatus(log: pointLog!, approve: approve, message: message, updating: true, indexPath: indexPath!)
                }
            }
            else if (preViewContr is UserPointsTableViewController) {
                if let userPointsViewContr = (preViewContr as! UserPointsTableViewController?){
                    userPointsViewContr.updatePointLogStatus(log: pointLog!, approve: approve, message: message, updating: true, indexPath: indexPath!)
                }
            }
            else if (preViewContr is NotificationsTableViewController) {
                if let notificationsViewContr = (preViewContr as! NotificationsTableViewController?){
                    notificationsViewContr.updatePointLogStatus(log: pointLog!, approve: approve, message: message, updating: true, indexPath: indexPath!)
                }
            }
		} else {
            if (preViewContr is RHPApprovalTableViewController) {
                if let rhpApprovalViewContr = (preViewContr as! RHPApprovalTableViewController?){
                    rhpApprovalViewContr.updatePointLogStatus(log: pointLog!, approve: approve, message: message, updating: false, indexPath: indexPath!)
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
	
	@objc func refreshData(){
        
        FirebaseHelper().getPointLogByID(pointLogID: pointLog!.logID!) { pointLog, err in
            if (err != nil) {
                print(err?.localizedDescription)
            } else {
                self.pointLog = pointLog
            }
        }
        
		DataManager.sharedManager.getMessagesForPointLog(pointLog: pointLog!, onDone: { (messageLogs:[MessageLog]) in
			// TODO: Probably a cleaner implementation of this??
			self.messageLogs = messageLogs
//			DispatchQueue.main.async { [unowned self] in
//				self.tableView.reloadData()
//			}
			self.tableView.reloadData()
			self.tableView.refreshControl?.endRefreshing()
		})
	}

	@IBAction func sendMessage(_ sender: Any) {
		let message = typeMessageField.text!
        self.view.endEditing(true)
        if (message != "") {
            self.sendButton.isEnabled = false
            sendActivityIndicator.isHidden = false
            sendActivityIndicator.startAnimating()
            DataManager.sharedManager.addMessageToPointLog(message: message, pointID: pointLog!.logID!) { (err) in
                if (err == nil) {
                    self.messageLogs.append(MessageLog(creationDate: Timestamp(), message: message, senderFirstName: User.get(.firstName) as! String, senderLastName: User.get(.lastName) as! String, senderPermissionLevel:  PointType.PermissionLevel(rawValue: User.get(.permissionLevel) as! Int)!, messageType: .comment))
                    self.tableView.reloadData()
                    self.scrollToBottom()
                    self.typeMessageField.text! = ""
                }
                self.sendButton.isEnabled = true
                self.sendActivityIndicator.stopAnimating()
                self.sendActivityIndicator.isHidden = true
            }
				
		}
	}
	
//	// Todo: Does this function need to be implemented?
//	func numberOfSections(in tableView: UITableView) -> Int {
//		return 1
//	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return messageLogs.count + 1 // Account for the first cell that is the point description
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		for view in cell.subviews {
			view.removeFromSuperview()
		}
		cell.backgroundColor = DefinedValues.systemGray5
		
		if (indexPath.row == 0) {
			let pointDescriptionView = PointDescriptionView()
            pointDescriptionView.delegate = self
			pointDescriptionView.setLog(pointLog: pointLog!)
			pointDescriptionView.layer.cornerRadius = radius
			pointDescriptionView.layer.shadowColor = UIColor.lightGray.cgColor
			pointDescriptionView.layer.shadowOpacity = 0.5
			pointDescriptionView.layer.shadowOffset = CGSize.zero
			pointDescriptionView.layer.shadowRadius = 4
			cell.addSubview(pointDescriptionView)
		
			pointDescriptionView.translatesAutoresizingMaskIntoConstraints = false
			let horizontalConstraint = NSLayoutConstraint(item: pointDescriptionView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
			let verticalConstraint = NSLayoutConstraint(item: pointDescriptionView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 22)
			let widthConstraint = NSLayoutConstraint(item: pointDescriptionView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
			
			NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint])
			
			let cellHeight = NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal, toItem: pointDescriptionView, attribute: .height, multiplier: 1, constant: 35)
			NSLayoutConstraint.activate([cellHeight])
			
			
		} else {
		
			let messageView = MessageView.init()
			messageView.setLog(messageLog: messageLogs[indexPath.row - 1])
			messageView.layer.cornerRadius = radius
			messageView.layer.shadowColor = UIColor.lightGray.cgColor
			messageView.layer.shadowOpacity = 0.5
			messageView.layer.shadowOffset = CGSize.zero
			messageView.layer.shadowRadius = 4
			messageView.messageLabel.autoresizingMask = [.flexibleHeight]
			messageView.autoresizingMask = [.flexibleHeight]
			messageView.sizeToFit()
			cell.addSubview(messageView)
			
			messageView.translatesAutoresizingMaskIntoConstraints = false
			let horizontalConstraint = NSLayoutConstraint(item: messageView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
			let verticalConstraint = NSLayoutConstraint(item: messageView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 22)
			let widthConstraint = NSLayoutConstraint(item: messageView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 1, constant: -20)
			
			NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint])
			let cellHeight = NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal, toItem: messageView, attribute: .height, multiplier: 1, constant: 35)
			NSLayoutConstraint.activate([cellHeight])
			
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
	
    
    func segueToProfilePointView() {
        self.performSegue(withIdentifier: "change_point_type", sender: self)
    }
    
    func goToNextScene() {
        let storyboard = UIStoryboard(name: "PointApproval", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditPointTypeController") as! EditSubmissionPointTypeViewController
        vc.title = "Edit Point Type"
        vc.pointLog = self.pointLog
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
	// TODO: Update this implementation. I can't imagine it being very efficient or scalable. Plus it doesn't use constants so changing constraints elsewhere would completely throw this off
    
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if (User.get(.permissionLevel) as! Int == 1) {
				if (approveButton != nil && rejectButton != nil) {
					approveButton!.isHidden = true
					rejectButton!.isHidden = true
				}
			}
			bottomConstraint.constant = -1 * (60 + keyboardSize.height - (self.tabBarController?.tabBar.frame.size.height)!)
			self.tableView.layoutIfNeeded()
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		if (User.get(.permissionLevel) as! Int != 1 || (approveButton == nil && rejectButton == nil)) {
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
	
	
	func scrollToBottom() {
        let indexPath = IndexPath(row: self.messageLogs.count, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//		if (self.tableView.visibleCells.count > 1) {
//			let bottomOffset = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.bounds.size.height)
//			self.tableView.setContentOffset(bottomOffset, animated: true)
//		}
	}
	
}
