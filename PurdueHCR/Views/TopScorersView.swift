//
//  TopScorersView.swift
//  PurdueHCR
//
//  Created by Benjamin Hardin on 1/6/20.
//  Copyright © 2020 DecodeProgramming. All rights reserved.
//

import UIKit

class TopScorersView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: "cell")
        return cell!
    }
    

}
