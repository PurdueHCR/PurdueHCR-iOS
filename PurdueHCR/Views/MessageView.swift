//
//  MessageView.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 7/30/19.
//  Copyright © 2019 DecodeProgramming. All rights reserved.
//

import UIKit

class MessageView: UIView {
	
	@IBOutlet var messageView: UIView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var messageIcon: UIImageView!
	@IBOutlet weak var grayView: UIView!
	

	override init(frame: CGRect) {
		super.init(frame: frame)
		Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)
		addSubview(messageView)
		nameLabel.text = "Hello, world!"
		messageView.frame = self.bounds
		self.messageView.layer.cornerRadius = 10
		messageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		messageIcon.image = #imageLiteral(resourceName: "approve")
		messageIcon.backgroundColor = UIColor.green
		messageIcon.layer.cornerRadius = messageIcon.layer.frame.height / 2
		grayView.layer.cornerRadius = DefinedValues.radius
		grayView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
	}
	
	required init(coder aDecoder: NSCoder){
		super.init(coder: aDecoder)!
	}
	
	func setLog(messageLog:MessageLog) {
		nameLabel.text = messageLog.senderFirstName + " " + messageLog.senderLastName
		messageLabel.text = messageLog.message
		let type = messageLog.messageType
		if (type == .approve) {
			messageIcon.backgroundColor = DefinedValues.green
			messageIcon.image = #imageLiteral(resourceName: "approve")
		}
		else if (type == .reject) {
			messageIcon.backgroundColor = DefinedValues.red
			messageIcon.image = #imageLiteral(resourceName: "reject")
		}
		else if (type == .comment) {
			messageIcon.backgroundColor = DefinedValues.yellow
			messageIcon.image = #imageLiteral(resourceName: "comment")
		}
	}
	
}
