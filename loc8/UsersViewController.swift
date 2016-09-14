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
    var message: Message?
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    let cellID = "cellID"
    var curUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
        
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        
        let someImage = "blueNumberEight"
        
        
        if(messages.count > indexPath.row) {
            
            let message = messages[indexPath.row]
            cell.message = message
        
        }

        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.imageView?.image = UIImage(named: someImage)
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let user = User()
        

        if(messages.count > indexPath.row) {
            let message = self.messages[indexPath.row]
            
            guard let chatPartnerID = message.chatPartnerID() else {
                return
            }
        
        
            let ref = FIRDatabase.database().reference().child("users").child(chatPartnerID)
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject]
                    else {
                        return
                }
                
                user.id = chatPartnerID
                user.setValuesForKeysWithDictionary(dictionary)
                self.curUser = user
                self.performSegueWithIdentifier("showChatLog", sender: nil)
                
            }, withCancelBlock: nil)
        }else {
            let tempUser = users[indexPath.row]
            curUser = tempUser
            performSegueWithIdentifier("showChatLog", sender: nil)
        }
        
    
    }

    
    func fetchUser() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
                        
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                user.setValuesForKeysWithDictionary(dictionary)
                user.id = snapshot.key
                
                if(uid != snapshot.key){
                    self.users.append(user)
                }
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
            
        }, withCancelBlock: nil)
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
    }
    
    
    func observeUserMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("userMessages").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let userID = snapshot.key
            
            FIRDatabase.database().reference().child("userMessages").child(uid).child(userID).observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                let messageID = snapshot.key
                
                let messagesReference = FIRDatabase.database().reference().child("messages").child(messageID)
                messagesReference.observeEventType(.Value, withBlock: { (snapshot) in
                    
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        
                        let message = Message()
                        message.setValuesForKeysWithDictionary(dictionary)
                        
                        if let toID = message.toID {
                            self.messagesDictionary[toID] = message
                            self.attemptReloadOfTable()
                            
                        }
                        
                        self.attemptReloadOfTable()
                        
                    }
                    
                    
                    }, withCancelBlock: nil)
                
                
                }, withCancelBlock: nil)

            
            }, withCancelBlock: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)
        let chatViewController = segue.destinationViewController as! ChatLogControllerJSQ
        //let navigationViewController = segue.destinationViewController as! UINavigationController
        //let chatViewController = navigationViewController.viewControllers.first as! ChatLogControllerJSQ
        chatViewController.senderId = curUser.id
        chatViewController.senderDisplayName = curUser.name
        chatViewController.user = curUser

    }
    
    var timer: NSTimer?

    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadTable), userInfo:  nil, repeats: false)
    }
    
    
    
    func handleReloadTable() {
        
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sortInPlace({ (message1, message2) ->
            Bool in
            
            return message1.timestamp?.intValue > message2.timestamp?.intValue
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
}