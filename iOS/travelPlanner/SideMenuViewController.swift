//
//  SideMenuViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var menuTableView: UITableView?
    var icon_userInfo: UIImageView?
    var icon_schedule: UIImageView?
    var imageView_avatar: UIImageView?
    var currentEntryIndex = 1
    
    var username = ""
    
    let menuEntryHeight: CGFloat = 54
    let numberOfMenuEntries = 5
    static let cellIdnetifier = "menuEntryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.username = Singleton_CurrentUser.sharedInstance.username
        
        self.icon_userInfo = UIImageView(frame: CGRectMake(15, (self.menuEntryHeight - 20) / 2, 20, 20))
        self.icon_userInfo?.image = UIImage(named: "person")
        self.icon_userInfo?.image = self.icon_userInfo?.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.icon_userInfo?.tintColor = UIColor.whiteColor()
        
        self.icon_schedule = UIImageView(frame: CGRectMake(15, (self.menuEntryHeight - 20) / 2, 20, 20))
        self.icon_schedule?.image = UIImage(named: "calendar")
        self.icon_schedule?.image = self.icon_schedule?.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.icon_schedule?.tintColor = UIColor.whiteColor()
        
        self.imageView_avatar = UIImageView(frame: CGRectMake(15, (self.menuEntryHeight - 40) / 2, 40, 40))
        self.imageView_avatar?.backgroundColor = UIColor.whiteColor()
        self.imageView_avatar?.layer.borderWidth = 1.0
        self.imageView_avatar?.layer.borderColor = UIColor.whiteColor().CGColor
        self.imageView_avatar?.layer.masksToBounds = true
        self.imageView_avatar?.layer.cornerRadius = self.imageView_avatar!.frame.size.width / 2

        self.menuTableView = UITableView(frame: CGRectMake(0, (self.view.frame.size.height - self.menuEntryHeight * CGFloat(self.numberOfMenuEntries)) / 2.0, self.view.frame.size.width, self.menuEntryHeight * CGFloat(self.numberOfMenuEntries)))
        self.menuTableView?.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleWidth]
        self.menuTableView?.delegate = self
        self.menuTableView?.dataSource = self
        self.menuTableView?.opaque = false
        self.menuTableView?.backgroundColor = UIColor.clearColor()
        self.menuTableView?.separatorStyle = .None
        self.menuTableView?.bounces = false
        
        self.view.addSubview(self.menuTableView!)
        
        // listen to teamRecordSavedOrUpdated message and handles it by updating team info in current view controller
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUserInfo", name: "userInfoUpdated", object: nil)
    }
    
    /**
     User name or avatar changed possibly, reload the user info
     */
    func updateUserInfo() {
        self.menuTableView?.reloadData()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if indexPath.row != self.currentEntryIndex {
            switch indexPath.row {
            case 1:
                let userInfoNavigationController = storyboard.instantiateViewControllerWithIdentifier("userInfoNavigationController") as! UINavigationController
                userInfoNavigationController.setViewControllers([storyboard.instantiateViewControllerWithIdentifier("userInfoTableViewController")], animated: true)
                self.sideMenuViewController.setContentViewController(userInfoNavigationController, animated: true)
                
                self.icon_userInfo?.tintColor = UIColor.lightGrayColor()
                self.icon_schedule?.tintColor = UIColor.whiteColor()
                break
            case 2:
                let scheduleNavigationController = storyboard.instantiateViewControllerWithIdentifier("scheduleNavigationController") as! UINavigationController
                scheduleNavigationController.setViewControllers([storyboard.instantiateViewControllerWithIdentifier("scheduleViewController")], animated: true)
                self.sideMenuViewController.setContentViewController(scheduleNavigationController, animated: true)
                
                self.icon_userInfo?.tintColor = UIColor.whiteColor()
                self.icon_schedule?.tintColor = UIColor.lightGrayColor()
                break
            default:
                break
            }
            self.currentEntryIndex = indexPath.row
        }
        self.sideMenuViewController.hideMenuViewController()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.menuEntryHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfMenuEntries
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(SideMenuViewController.cellIdnetifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: SideMenuViewController.cellIdnetifier)
            cell?.backgroundColor = UIColor.clearColor()
            cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 17)
            cell?.textLabel?.textColor = UIColor.whiteColor()
            cell?.textLabel?.highlightedTextColor = UIColor.lightGrayColor()
            cell?.selectedBackgroundView = UIView()
        }
        
        switch indexPath.row {
        case 0:
            Toolbox.loadAvatarImage(Singleton_CurrentUser.sharedInstance.userId, toImageView: self.imageView_avatar!)
            cell?.textLabel?.text = "           \(Singleton_CurrentUser.sharedInstance.username)"
            cell?.textLabel?.highlightedTextColor = UIColor.whiteColor()
            cell?.contentView.addSubview(self.imageView_avatar!)
            break
        case 1:
            cell?.textLabel?.text = "        User info"
            cell?.contentView.addSubview(self.icon_userInfo!)
            break
        case 2:
            cell?.textLabel?.text = "        Schedule"
            cell?.contentView.addSubview(self.icon_schedule!)
            break
        default:
            break
        }
        return cell!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
