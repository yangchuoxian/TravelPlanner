//
//  ScheduleViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var currentSelectedSegmentIndex = 0
    
    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: self, action: "presentLeftMenuViewController:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .Plain, target: self, action: "showNewScheduleViewController")
    }

    func showNewScheduleViewController() {
        self.performSegueWithIdentifier("newScheduleSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Appearance.customizeNavigationBar(self, title: "Schedule")
        self.currentSelectedSegmentIndex = self.segmentControl.selectedSegmentIndex
    }

    @IBAction func switchSegmentView(sender: AnyObject) {
        let selectedSegmentIndex = (sender as! UISegmentedControl).selectedSegmentIndex
        if self.currentSelectedSegmentIndex != selectedSegmentIndex {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if selectedSegmentIndex == 0 {          // change to monthly schedule view controller
                self.view.endEditing(true)
                let monthlyScheduleViewController = storyboard.instantiateViewControllerWithIdentifier("monthlyScheduleViewController")
                
                if self.childViewControllers.count > 0 {
                    // remove previously added child view controller and its view if any
                    self.childViewControllers[0].removeFromParentViewController()
                    self.containerView.subviews[0].removeFromSuperview()
                }
                
                self.addChildViewController(monthlyScheduleViewController)
                self.containerView.addSubview(monthlyScheduleViewController.view)
                monthlyScheduleViewController.didMoveToParentViewController(self)
                self.currentSelectedSegmentIndex = 0
            } else if selectedSegmentIndex == 1 {   // change to filter schedule view controller
                self.view.endEditing(true)
                let filterScheduleViewController = storyboard.instantiateViewControllerWithIdentifier("filterScheduleViewController")
                
                if self.childViewControllers.count > 0 {
                    // remove previously added child view controller and its view if any
                    self.childViewControllers[0].removeFromParentViewController()
                    self.containerView.subviews[0].removeFromSuperview()
                }
                
                self.addChildViewController(filterScheduleViewController)
                self.containerView.addSubview(filterScheduleViewController.view)
                filterScheduleViewController.didMoveToParentViewController(self)
                self.currentSelectedSegmentIndex = 1
            } else if selectedSegmentIndex == 2 {   // change to search schedule view controller
                self.view.endEditing(true)
                let searchScheduleViewController = storyboard.instantiateViewControllerWithIdentifier("searchScheduleViewController")
                
                if self.childViewControllers.count > 0 {
                    // remove previously added child view controller and its view if any
                    self.childViewControllers[0].removeFromParentViewController()
                    self.containerView.subviews[0].removeFromSuperview()
                }

                self.addChildViewController(searchScheduleViewController)
                self.containerView.addSubview(searchScheduleViewController.view)
                searchScheduleViewController.didMoveToParentViewController(self)
                self.currentSelectedSegmentIndex = 2
            }
        }
    }
    
    @IBAction func unwindToScheduleViewController(segue: UIStoryboardSegue) {
    }
    
}
