//
//  TopScorersView.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/6/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

class TopScorersView: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var insideTableView: UITableView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "this_cell_right_here")
        cell.backgroundColor = UIColor.black
        cell.textLabel?.text = "Hello, world!"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    
    

}
