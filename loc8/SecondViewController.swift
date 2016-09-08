//
//  SecondViewController.swift
//  loc8
//
//  Created by ivy_p on 8/11/16.
//  Copyright © 2016 risingDev. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    
    @IBAction func LogoutButton(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let AuthVC = storyboard.instantiateViewControllerWithIdentifier("AuthVC") as! AuthViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = AuthVC
        
        
        //need handle logout method
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

