//
//  LoginViewController.swift
//  loc8
//
//  Created by ivy_p on 8/12/16.
//  Copyright © 2016 risingDev. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginEmailTextField: UITextField!
    
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    @IBAction func LoginButton(sender: AnyObject) {
        handleLogin()
       
    }
    
    

    
    func handleLogin() {
        
        guard let email = loginEmailTextField.text, password = loginPasswordTextField.text else{
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            
            if(error != nil){
                print(error)
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let TabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = TabBarController
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        })
        
    }
    

    

}
