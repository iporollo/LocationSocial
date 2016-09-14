//
//  ChatLogControllerJSQ2.swift
//  loc8
//
//  Created by ivy_p on 9/12/16.
//  Copyright © 2016 risingDev. All rights reserved.
//

import Firebase
import JSQMessagesViewController

class ChatLogControllerJSQ: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var user = User()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.name
        setupBubbles()
        
        //needs to be set up to show images
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == user.id {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        
        if message.senderId == user.id {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    //needs to be set up to print user image
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    func addMessage(id: String, name: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: name, text: text)
        messages.append(message)
    }
    

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,senderDisplayName: String!, date: NSDate!) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = user.id!
        let fromID = FIRAuth.auth()!.currentUser!.uid
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        let values = ["text": text, "toID": toID, "fromID": fromID, "timestamp": timestamp]
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


        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
    }
    
    private func observeMessages() {
        
        let tempUser = User()
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, toID = user.id else {
            return
        }
        
        
        let userMessagesRef = FIRDatabase.database().reference().child("userMessages").child(uid).child(toID)
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageID)
            let messagesQuery = messagesRef.queryLimitedToLast(25) //idk what this does, will need to check
            messagesQuery.observeEventType(.Value, withBlock: { (snapshot) in
                
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeysWithDictionary(dictionary)
                
                //for the user names
                let ref = FIRDatabase.database().reference().child("users").child(message.toID!)
                ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject]
                        else {
                            return
                    }
                    
                    tempUser.setValuesForKeysWithDictionary(dictionary)
                
                    self.addMessage(message.toID!, name: tempUser.name!,  text: message.text!)
                
                    dispatch_async(dispatch_get_main_queue(), {
                            self.collectionView?.reloadData()
                    })
                
                }, withCancelBlock: nil)

                
            }, withCancelBlock: nil)
            
        }, withCancelBlock: nil)
        
        self.finishReceivingMessage()
    }
    
    
}
