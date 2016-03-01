//
//  ScheduleResultsTableViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class ScheduleResultsTableViewController: UITableViewController, MGSwipeTableCellDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {

    var schedules = [Schedule]()
    var selectedSchedule: Schedule?
    var responseData: NSMutableData? = NSMutableData()
    var HUD: MBProgressHUD?
    var deletingScheduleIndex: Int?
    
    deinit {
        self.selectedSchedule = nil
        self.schedules.removeAll()
        self.responseData = nil
        self.HUD = nil
        self.deletingScheduleIndex = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        
        self.tableView.rowHeight = 80
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // when a schedule is updated, the table view should reflect the updates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showUpdatedSchedule:", name: "scheduleUpdated", object: nil)
    }
    
    func showUpdatedSchedule(notification: NSNotification) {
        let updatedSchedule = notification.object as! Schedule
        let possibleCandidates = self.schedules.filter{
            $0.scheduleId == updatedSchedule.scheduleId
        }
        if possibleCandidates.count > 0 {
            let relatedScheduleInList = possibleCandidates[0]
            let index = self.schedules.indexOf(relatedScheduleInList)
            self.schedules[index!] = updatedSchedule
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Appearance.customizeNavigationBar(self, title: "Schedule results")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("scheduleCell") as? MGSwipeTableCell
        if cell == nil {
            cell = MGSwipeTableCell(style: .Default, reuseIdentifier: "scheduleCell")
        }
        let scheduleInCurrentRow = self.schedules[indexPath.row]
        // set up schedule info and show in current table cell
        let label_cityOfDeparture = cell?.contentView.viewWithTag(1) as! UILabel
        let label_cityOfArrival = cell?.contentView.viewWithTag(2) as! UILabel
        let label_startDate = cell?.contentView.viewWithTag(3) as! UILabel
        let label_dayCount = cell?.contentView.viewWithTag(4) as! UILabel
        
        label_cityOfDeparture.text = scheduleInCurrentRow.cityOfDeparture
        label_cityOfArrival.text = scheduleInCurrentRow.cityOfArrival
        
        let startDate = NSDate(dateString: scheduleInCurrentRow.startDate)
        label_startDate.text = startDate.getDateString()
        
        let now = NSDate()
        
        if now.compare(startDate) == .OrderedAscending {
            let numberOfDaysLeftFromNow = now.getNumberOfDaysUntil(startDate)
            label_dayCount.text = "\(numberOfDaysLeftFromNow) days left"
        } else {
            label_dayCount.hidden = true
        }
        cell!.delegate = self
        cell!.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor())]
        
        return cell!
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        if direction == .RightToLeft {
            let indexPath = self.tableView.indexPathForCell(cell)
            let scheduleToDelete = self.schedules[indexPath!.row]
            
            let connection = Toolbox.asyncHttpPostToURL(URLDeleteUserSchedule, parameters: "id=\(scheduleToDelete.scheduleId)", delegate: self)
            if connection == nil {
                Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network connection failed")
            } else {
                self.deletingScheduleIndex = indexPath!.row
                self.HUD = Toolbox.setupCustomProcessingViewWithTitle(title: nil)
            }
        }
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedSchedule = self.schedules[indexPath.row]
        self.performSegueWithIdentifier("scheduleDetailSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scheduleDetailSegue" {
            let destinationViewController = segue.destinationViewController as! ScheduleDetailTableViewController
            destinationViewController.currentSchedule = self.selectedSchedule
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.responseData?.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.HUD?.hide(true)
        self.HUD = nil
        Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network timeout")
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.HUD?.hide(true)
        self.HUD = nil
        
        let responseStr = NSString(data: self.responseData!, encoding: NSUTF8StringEncoding)
        if responseStr == "OK" {
            Toolbox.showCustomAlertViewWithImage("checkmark", title: "Schedule deleted successfully")
            self.schedules.removeAtIndex(self.deletingScheduleIndex!)
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: self.deletingScheduleIndex!, inSection: 0)], withRowAnimation: .Right)
        } else {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "\(responseStr!)")
        }
    }
    
}
