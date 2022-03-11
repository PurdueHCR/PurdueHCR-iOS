//
//  QRSelectPointTypeTableViewCell.swift
//  PurdueHCR
//
//  Created by Brennan Doyle on 2/28/22.
//  Copyright © 2022 DecodeProgramming. All rights reserved.
//

import UIKit

class QRSelectPointTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pointTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
