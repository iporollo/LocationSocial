//
//  RegisterViewController.swift
//  loc8
//
//  Created by ivy_p on 8/12/16.
//  Copyright © 2016 risingDev. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var registerNameTextField: UITextField!

    @IBOutlet weak var registerEmailTextField: UITextField!
    
    @IBOutlet weak var registerPasswordTextField: UITextField!
    
    
    @IBAction func RegisterButton(sender: AnyObject) {
        handleRegister()
    }
    

    func handleRegister() {
        
        guard let email = registerEmailTextField.text, password = registerPasswordTextField.text, name = registerNameTextField.text else {
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let values = ["name": name, "email": email]
            
            self.registerUserIntoDatabaseWithUID(uid, values: values)
            
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let TabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = TabBarController

            
            
//            //successfully authenticated user
//            let imageName = NSUUID().UUIDString
//            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
//            
//            if let profileImage = self.appImageView.image, uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
//                
//                
//                
//                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
//                    
//                    if error != nil {
//                        print(error)
//                        return
//                    }
//                    
//                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
//                        
//                        let values = ["name": name, "email": email, "appImageUrl": profileImageUrl]
//                        
//                        self.registerUserIntoDatabaseWithUID(uid, values: values)
//                    }
//                })
//            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().referenceFromURL("https://loc8-1230b.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err)
                return
            }
            
            //self.messagesController?.fetchUserAndSetupNavBarTitle() --- idk if this is needed at all, look at later
            
            
            //self.messagesController?.navigationItem.title = values["name"] as? String
            //puts logged in user's name into title of page
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }

}
