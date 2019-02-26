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

class LinkCodesTableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    var links = LinkList()
    var filteredLinks = [Link]()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.clearsSelectionOnViewWillAppear = true

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search QR Codes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        let label = UILabel(frame: CGRect(origin: self.tableView.frame.origin, size: CGSize(width: 200, height: 40)))
        label.text = "No QR Codes to show"
        self.tableView.backgroundView = label
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refresher
        getData(refresh: true)
    }
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredLinks = links.allLinks.filter({( link : Link) -> Bool in
            return link.description.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    @objc func refreshData(){
        getData(refresh: true)
    }

    func getData(refresh:Bool){
        let ownerID = User.get(.id) as! String
        DataManager.sharedManager.getQRCodeFor(ownerID: ownerID, withRefresh: refresh, withCompletion:{(linksOptional:LinkList?) in
            guard let links = linksOptional else{
                return
            }
            self.links = links
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.links.reloadLinks()
        if(self.links.unarchivedLinks.count == 0 && self.tableView.numberOfSections != 0 && self.searchController.searchBar.text == ""){
            let indexSet = NSMutableIndexSet()
            indexSet.add(0)
            self.tableView.deleteSections(indexSet as IndexSet, with: .automatic)
        }
        self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(isFiltering()){
            if(filteredLinks.count > 0){
                killEmptyMessage()
                return 1
            }
            else {
                emptyMessage(message: "No codes found.")
                return 0
            }
        }
        else{
            if self.links.unarchivedLinks.count > 0 {
                killEmptyMessage()
                return 1
            } else if self.links.archivedLinks.count > 0{
                emptyMessage(message: "You don't have any unarchived QR codes.")
                return 0
            }
            else{
                emptyMessage(message: "You haven't created any QR codes.")
                return 0
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(isFiltering()){
            return filteredLinks.count
        }
        else{
            return links.unarchivedLinks.count
        }
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "link_cell", for: indexPath) as! LinkCell
        if(isFiltering()){
            cell.descriptionLabel.text = self.filteredLinks[indexPath.row].description
            cell.activeView.layer.cornerRadius = cell.activeView.frame.width / 2
            cell.activeView.backgroundColor = UIColor.red
            if(self.filteredLinks[indexPath.row].enabled){
                cell.activeView.backgroundColor = UIColor.green
            }
        }
        else {
            cell.descriptionLabel.text = self.links.unarchivedLinks[indexPath.row].description
            cell.activeView.layer.cornerRadius = cell.activeView.frame.width / 2
            cell.activeView.backgroundColor = UIColor.red
            if(self.links.unarchivedLinks[indexPath.row].enabled){
                cell.activeView.backgroundColor = UIColor.green
            }
        }
        // Configure the cell...
        return cell
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "QR_Show", sender: self)
        
    }
 
    func addLinkToList(link:Link) {
        self.links.allLinks.append(link)
        self.links.reloadLinks()
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
            if(isFiltering()){
                nextViewController.link = self.filteredLinks[indexPath!.row]
            }
            else{
                nextViewController.link = self.links.unarchivedLinks[indexPath!.row]
            }
        }
        if(segue.identifier == "QR_Init"){
            //Pass in the array of lists so that when a new code is created it will be appended to this list;
            // when this table view is shown again, it will therefore have a reference for the new Link
            let nextViewController = segue.destination as! QRCodeGeneratorViewController
            nextViewController.appendMethod = addLinkToList
        }
        
    }
    

}
