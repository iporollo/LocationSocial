//
//  FirstViewController.swift
//  loc8
//
//  Created by ivy_p on 8/11/16.
//  Copyright © 2016 risingDev. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UITableViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
        print("here")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        let user = users[indexPath.row]
        let someImage = "blueNumberEight"
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.imageView?.image = UIImage(named: someImage)
        
        return cell
    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                user.setValuesForKeysWithDictionary(dictionary)
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
                //                user.name = dictionary["name"]
            }
            
            }, withCancelBlock: nil)
    }

    
    
}

