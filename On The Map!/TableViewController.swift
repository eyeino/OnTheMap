//
//  SecondViewController.swift
//  On The Map!
//
//  Created by Ian MacFarlane on 8/1/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    @IBAction func logoutButton(sender: AnyObject) {
        UdacityClient.sharedInstance().logoutWithUdacity(self) { (success, error) in
            if success {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true, completion: {
                        //set stored user details back to nil upon logout
                        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
                        delegate?.udacityUserID = nil
                        delegate?.udacitySessionID = nil
                    })
                }
            } else {
                print("Logout failure: \(error)")
            }
        }
    }
    
    var students: [StudentInformation] {
        get {
            let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
            if let students = delegate?.students {
                return students
            } else {
                return [StudentInformation]()
            }
        }
    }
    
    @IBOutlet weak var createLocationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.reloadData()
        
        
    }
    
    let reuseIdentifier = "StudentTableCell"
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)!
        let student = students[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = "\(student.firstName!) \(student.lastName!)"
        cell.detailTextLabel?.text = student.mediaURL!

        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let url = students[indexPath.row].mediaURL
        let app = UIApplication.sharedApplication()
        
        if self.verifyUrl(url) {
            app.openURL(NSURL(string: url!)!)
        } else {
            let alert = UIAlertController(title: "Error", message: "User did not supply a valid URL.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(okAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    //checks if URL is indeed a valid URL
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
    */


}

