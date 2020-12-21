//
//  SelectedFloorsTableViewCell.swift
//  PurdueHCR
//
//  Created by Brennan Doyle on 11/6/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

class SelectedFloorsTableViewCell: UITableViewCell {

    @IBOutlet weak var floorLabel: UILabel!
    var floorSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
