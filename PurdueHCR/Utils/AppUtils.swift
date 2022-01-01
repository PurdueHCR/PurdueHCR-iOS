//
//  AppUtils.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/22/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import UIKit
import NotificationBannerSwift

class AppUtils {
    
    static func getColorForThisHouse(house:String) -> UIColor {
        return AppUtils.hexStringToUIColor(hex: "5AC0C7")
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class AtomicCounter {
        private var queue:DispatchQueue
        private (set) var value: Int = 0
        
        init(identifier:String){
            queue = DispatchQueue(label: identifier)
        }
        
        func increment() {
            queue.sync {
                value += 1
            }
        }
        
        func reset(){
            queue.sync {
                value = 0
            }
        }
    }
    
}



extension UIViewController {
    func notify(title:String,subtitle:String, style:BannerStyle){
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
        banner.duration = 2
        banner.show()
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


extension UITableViewController {
    func emptyMessage(message:String) {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.bounds.size.width - 20, height: self.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
		messageLabel.accessibilityIdentifier = "Empty Message"
        if #available(iOS 13.0, *) {
            messageLabel.textColor = UIColor.label
        } else {
            messageLabel.textColor = .black
        }
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
    }
    func killEmptyMessage(){
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
    }
}


// Class to verify when the app is launched for the first time.
final class NewLaunch {
    
    public static let newLaunch = NewLaunch(userDefaults: .standard, key: "com.purdueHCR.IsNewLaunch")
    
    let wasLaunchedBefore: Bool
    let setWasLaunchedBefore: ((Bool) -> ())
    
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    init(getWasLaunchedBefore: () -> Bool,
         setWasLaunchedBefore: @escaping (Bool) -> ()) {
        self.setWasLaunchedBefore = setWasLaunchedBefore
        let wasLaunchedBefore = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            setWasLaunchedBefore(true)
        }
    }
    
    convenience init(userDefaults: UserDefaults, key: String) {
        self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
                  setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
    }
    
}

