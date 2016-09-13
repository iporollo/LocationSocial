//
//  ChatLogController - TableViewController.swift
//  loc8
//
//  Created by ivy_p on 9/1/16.
//  Copyright © 2016 risingDev. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var messageInputField: UITextField!
    
    @IBAction func sendMessage(sender: AnyObject) {
        handleSend()
        
//needs to reload view to show new message
        
        dispatch_async(dispatch_get_main_queue(), {
            //self.reloadInputViews()
            //idk if this will work
            self.collectionView?.reloadData()
        })
        
        self.view.window?.endEditing(true)
        
        self.messageInputField.text = ""
    }
    
    
    var user = User() {
        didSet {
            //set header text through IBA link to user name
            observeMessages()
        }
    }
    
    
    var messages = [Message]()
    
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, toID = user.id else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("userMessages").child(uid).child(toID)
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageID)
            messagesRef.observeEventType(.Value, withBlock: {(snapshot) in
                
                print(snapshot)
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeysWithDictionary(dictionary)
                
                self.messages.append(message)
                    
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView?.reloadData()
                })
                
                
                
                
                }, withCancelBlock: nil)
            
            }, withCancelBlock: nil)
    }
    
    
   let cellID = "messageCell"
    
   override func viewDidLoad() {
    
        super.viewDidLoad()
    
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = messages.count
        
        
        if(count < 1){
            count = 1
        }
        
        return count
        
    }
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! ChatMessageCell
        
        if(messages.count > indexPath.row) {
            let message = messages[indexPath.item]
            cell.messageText.text = message.text
        }

        
        return cell
    }
    
    
    func handleSend() {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = user.id!
        let fromID = FIRAuth.auth()!.currentUser!.uid
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        let values = ["text": messageInputField.text!, "toID": toID, "fromID": fromID, "timestamp": timestamp]
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error)
                return
            }
            
            let userMessagesRef = FIRDatabase.database().reference().child("userMessages").child(fromID).child(toID)
            
            let messageID = childRef.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("userMessages").child(toID).child(fromID)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
            
        }
        
    }

}