//
//  FirstViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 6/23/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class PointOptionViewController: UITableViewController{

    var pointSystem = [PointGroup]()
    
//    init(){
//        super.init(nibName:nil,bundle:nil)
//        pointSystem = DataManager.sharedManager.getPointGroups(onDone: { [weak self] (pg:[PointGroup]) in
//            self?.pointSystem = pg;
//            self?.tableView.reloadData()
//            print("Please relaod")
//        }) ?? [PointGroup]()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        pointSystem = DataManager.sharedManager.getPointGroups(onDone: { [weak self] (pg:[PointGroup]) in
//            self?.pointSystem = pg;
//            self?.tableView.reloadData()
//            print("Please relaod")
//        }) ?? [PointGroup]()
    //    }
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pointSystem = DataManager.sharedManager.getPointGroups(onDone: { [weak self] (pg:[PointGroup]) in
            if let strongSelf = self {
                strongSelf.pointSystem = pg;
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
                print("Please relaod")
            }
            else{
                print("self is nil")
            }
            
        }) ?? [PointGroup]()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let name = User.get(.name) as! String
        self.title = "Welcome "+name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Get the count: ", pointSystem[section].points.count)
        return (pointSystem[section].points.count);
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = pointSystem[indexPath.section].points[indexPath.row].pointDescription
        
        return(cell)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print("Get the numb sections: ", pointSystem.count)
        return (pointSystem.count)
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pointSystem[section].pointValue.description + " Points" ;
    }
    
    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "cell_push", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let nextViewController = segue.destination as! TypeSubmitViewController
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        nextViewController.type = pointSystem[(indexPath?.section)!].points[(indexPath?.row)!]
    }
}




