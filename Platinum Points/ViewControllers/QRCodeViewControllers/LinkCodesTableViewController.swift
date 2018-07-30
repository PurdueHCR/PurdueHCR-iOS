//
//  LinkCodesTableViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class LinkCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var activeView: UIView!
    
}

class LinkCodesTableViewController: UITableViewController {
    
    var codes = [Link]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let label = UILabel(frame: CGRect(origin: self.tableView.frame.origin, size: CGSize(width: 200, height: 40)))
        label.text = "No QR Codes to show"
        self.tableView.backgroundView = label
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        getData(refresh: true)
    }
    

    @objc func refreshData(){
        getData(refresh: true)
    }

    func getData(refresh:Bool){
        let ownerID = User.get(.id) as! String
        DataManager.sharedManager.getQRCodeFor(ownerID: ownerID, withRefresh: refresh, withCompletion:{(linksOptional:[Link]?) in
            guard let links = linksOptional else{
                return
            }
            self.codes = links
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if codes.count > 0 {
            killEmptyMessage()
            return 1
        } else {
            emptyMessage(message: "You haven't created any QR codes.")
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return codes.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "link_cell", for: indexPath) as! LinkCell
        cell.descriptionLabel.text = self.codes[indexPath.row].description
        cell.activeView.layer.cornerRadius = cell.activeView.frame.width / 2
        cell.activeView.backgroundColor = UIColor.red
        if(self.codes[indexPath.row].enabled){
            cell.activeView.backgroundColor = UIColor.green
        }
        // Configure the cell...
        return cell
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "QR_Show", sender: self)
        
    }
 
    func addLinkToList(link:Link) {
        self.codes.append(link)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let indexPath = tableView.indexPathForSelectedRow
        if(segue.identifier == "QR_Show"){
            let nextViewController = segue.destination as! LinkCodeViewController
            nextViewController.link = self.codes[indexPath!.row]
        }
        if(segue.identifier == "QR_Init"){
            //Pass in the array of lists so that when a new code is created it will be appended to this list;
            // when this table view is shown again, it will therefore have a reference for the new Link
            let nextViewController = segue.destination as! QRCodeGeneratorViewController
            nextViewController.appendMethod = addLinkToList
        }
        
    }
    

}
