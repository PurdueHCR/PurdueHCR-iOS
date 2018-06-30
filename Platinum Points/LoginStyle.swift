//
//  LoginStyle.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/30/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import Foundation
import Cely

struct CottonCandy: CelyStyle {
    func backgroundColor() -> UIColor {
        return UIColor(red: 86/255, green: 203/255, blue: 249/255, alpha: 1) // Changing Color
    }
    func buttonTextColor() -> UIColor {
        return .white
    }
    func buttonBackgroundColor() -> UIColor {
        return UIColor(red: 253/255, green: 108/255, blue: 179/255, alpha: 1) // Changing Color
    }
    func textFieldBackgroundColor() -> UIColor {
        return UIColor.white.withAlphaComponent(0.4)
    }
    func appLogo() -> UIImage? {
        return UIImage(named: "platinum-banner")
    }
}
