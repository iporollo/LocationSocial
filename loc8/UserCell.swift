//
//  UserCell.swift
//  loc8
//
//  Created by ivy_p on 9/1/16.
//  Copyright © 2016 risingDev. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var message: Message? {
        didSet {
            
            setupNameAndProfileImage()
            

            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.stringFromDate(timestampDate)
            }
        }
    }
    
    private func setupNameAndProfileImage() {
        
        
        
        if let ID = message?.chatPartnerID(){
            let ref = FIRDatabase.database().reference().child("users").child(ID)
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let someImage = "blueNumberEight"
                    self.imageView?.image = UIImage(named: someImage)

                    
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    //for profile pic later
                    
//                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
//                        self.imageView?.image = UIImage(named: someImage).loadImageUsingCacheWithUrlString(profileImageUrl)
//                    }
                }
                
            }, withCancelBlock: nil)
            
        }
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
//    init(coder decoder: NSCoder) {
//        super.init(coder: decoder)
//    }

}
