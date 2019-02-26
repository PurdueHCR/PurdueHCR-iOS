////
////  TextFieldMaxLengths.swift
////  PurdueHCR
////
////  Created by Benjamin Hardin on 10/17/18.
////  Copyright © 2018 DecodeProgramming. All rights reserved.
////
//
//// Original code an idea of Joey Devilla
//// on his "Global Nerdy" tech blog.
//
//import UIKit
//
//// 1
//private var maxLengths = [UITextView: Int]()
//
//// 2
//extension UITextView {
//	
//	// 3
//	@IBInspectable var maxLength: Int {
//		get {
//			// 4
//			guard let length = maxLengths[self] else {
//				return Int.max
//			}
//			return length
//		}
//		set {
//			maxLengths[self] = newValue
//			// 5
//			addTarget(
//				self,
//				action: #selector(limitLength),
//				for: UIControlEvents.editingChanged
//			)
//		}
//	}
//	
//	@objc func limitLength(textField: UITextView) {
//		// 6
//		guard let prospectiveText = textField.text,
//			prospectiveText.characters.count > maxLength
//			else {
//				return
//		}
//		
//		let selection = selectedTextRange
//		// 7
//		let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
//		text = prospectiveText.substring(to: maxCharIndex)
//		selectedTextRange = selection
//	}
//	
//}
