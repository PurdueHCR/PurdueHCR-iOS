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
    }
    
}



extension UIViewController {
    func notify(title:String,subtitle:String, style:BannerStyle){
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
        banner.duration = 2
        banner.show()
    }
    
}
