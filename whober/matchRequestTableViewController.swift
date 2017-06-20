//
//  matchRequestTableViewController.swift
//  whober
//
//  Created by Adam Glasdstone on 19/6/17.
//  Copyright © 2017 swiftary. All rights reserved.
//

import UIKit

class matchRequestTableViewController: UITableViewController {

    //MARK: Properties
    
    var matchRequests = [matchRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMatchRequests()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchRequests.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "matchRequestTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? matchRequestTableViewCell else {fatalError("The dequeued cell is not an instance of MealTableViewCell.")}
        

        // Fetches the appropriate meal for the data source layout.
        
        let Request = matchRequests[indexPath.row]
        
        
        cell.matchRequestFirstName.text = Request.firstName
        cell.matchRequestSurname.text = Request.surname
        cell.matchRequestStatus.text  = Request.matchStatus
        cell.matchRequestPhoto.image = Request.photo
        
        

        return cell
    }
    


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            matchRequests.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Private Methods
    
    private func loadMatchRequests() {
        
        let photo1 = UIImage(named: "faceMatch1")
        let photo2 = UIImage(named: "faceMatch2")
        let photo3 = UIImage(named: "faceMatch3")
        let photo4 = UIImage(named: "faceMatch4")
        
        guard let matchRequest1 = matchRequest(userId: "1123", requestId: "3445", photo: photo1, matchStatus: "Matched", firstName: "Angelina", surname: "Jolie")
            else { fatalError("Unable to load match 1") }
        
        guard let matchRequest2 = matchRequest(userId: "1123", requestId: "3445", photo: photo2, matchStatus: "Matched", firstName: "Charlize", surname: "Theron")
            else { fatalError("Unable to load match 2")}
        
        guard let matchRequest3 = matchRequest(userId: "1123", requestId: "3445", photo: photo3, matchStatus: "Matched", firstName: "Christian", surname: "Baile")
            else { fatalError("Unable to load match 3")}
        
        guard let matchRequest4 = matchRequest(userId: "1123", requestId: "3445", photo: photo4, matchStatus: "Matched", firstName: "Zac", surname: "Efron")
            else { fatalError("Unable to load match 4")}
        
        matchRequests += [matchRequest1,matchRequest2,matchRequest3,matchRequest4]
    }
    
    //MARK: Actions
    
    @IBAction func unwindToMatchRequestList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? ViewController, let request = sourceViewController.request {
            
            let newIndexPath = IndexPath(row: matchRequests.count, section: 0)
            
            matchRequests.append(request)
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
            
        }
        
    }
}
