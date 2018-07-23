//
//  ColorAndPictureView.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/15/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class ColorAndPictureView: UIView {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("ColorAndPicture", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let houseName = User.get(.house) as! String
        if(houseName == "Platinum"){
            imageView.image = #imageLiteral(resourceName: "Platinum")
        }
        else if(houseName == "Copper"){
            imageView.image = #imageLiteral(resourceName: "Copper")
        }
        else if(houseName == "Palladium"){
            imageView.image = #imageLiteral(resourceName: "Palladium")
        }
        else if(houseName == "Silver"){
            imageView.image = #imageLiteral(resourceName: "Silver")
        }
        else if(houseName == "Titanium"){
            imageView.image = #imageLiteral(resourceName: "Titanium")
        }
    }

}
