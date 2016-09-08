//
//  Message.swift
//  loc8
//
//  Created by ivy_p on 9/1/16.
//  Copyright © 2016 risingDev. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromID: String?
    var text: String?
    var timestamp: NSNumber?
    var toID: String?
    
    
    func chatPartnerID() -> String? {
        return fromID == FIRAuth.auth()?.currentUser?.uid ? toID : fromID
    }
    
}