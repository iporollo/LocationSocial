////
////  PageViewController.swift
////  loc8
////
////  Created by ivy_p on 9/10/16.
////  Copyright © 2016 risingDev. All rights reserved.
////
//
//import UIKit
//
//class PageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//
//    var pageController: UIPageViewController?
//    var pageContent = NSArray()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    func viewControllerAtIndex(index: Int) -> UIViewController? {
//        if(pageContent.count == 0) || (index >= pageContent.count) {
//            return nil
//        }
//        
//        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        let dataViewController = storyBoard.instantiateViewControllerWithIdentifier("usersChatting") as! UsersViewController // will be chaged to probably user view controller
//        dataViewController.dataObject = pageContent[index]
//        return dataViewController
//        
//    }
//    
//    func indexOfViewController(viewController: UsersViewController) -> Int {
//        if let dataObject: AnyObject = viewController.dataObject {
//            return pageContent.indexOfObject(dataObject)
//        } else {
//            return NSNotFound
//        }
//    }
//    
//    
//    
//    
//    
//    
//}
