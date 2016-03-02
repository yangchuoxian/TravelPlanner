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
    var scheduleResultType: ScheduleResultType?
    
    var currentPage: Int?
    var totalResults: Int?
    
    var dateRangeStart: String?
    var dateRangeEnd: String?
    var searchKeyword: String?
    
    var button_nextPage: UIButton?
    
    enum httpRequest {
        case DeleteSchedule
        case GetNextPageResults
    }
    var indexOfCurrentHttpRequest: httpRequest?
    
    deinit {
        self.selectedSchedule = nil
        self.schedules.removeAll()
        self.responseData = nil
        self.HUD = nil
        self.deletingScheduleIndex = nil
        self.scheduleResultType = nil
        
        self.currentPage = nil
        self.totalResults = nil
        
        self.dateRangeStart = nil
        self.dateRangeEnd = nil
        self.searchKeyword = nil
        self.button_nextPage = nil
        
        self.indexOfCurrentHttpRequest = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        
        self.tableView.rowHeight = 80
        self.currentPage = 1
        
        // when a schedule is updated, the table view should reflect the updates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showUpdatedSchedule:", name: "scheduleUpdated", object: nil)
        
        if self.schedules.count < self.totalResults {
            // if there are more results/more pages, add a next page button at table footer
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 70))
            self.button_nextPage = Appearance.setupTableFooterButtonWithTitle("More results", backgroundColor: ColorPrimaryBlue)
            self.button_nextPage?.addTarget(self, action: "getSchedulesOfNextPage", forControlEvents: .TouchUpInside)
            footerView.addSubview(self.button_nextPage!)
            self.tableView.tableFooterView = footerView
        } else {
            self.tableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    func getSchedulesOfNextPage() {
        let tempPage = self.currentPage! + 1
        var getUrl = ""
        if self.scheduleResultType == .FilterResult {
            getUrl = "\(URLFilterSchedules)?startTime=\(self.dateRangeStart!)&endTime=\(self.dateRangeEnd!)&page=\(tempPage)"
        } else if self.scheduleResultType == .SearchResult {
            getUrl = "\(URLSearchSchedules)?keyword=\(self.searchKeyword!)"
        }
        var connection = Toolbox.asyncHttpGetFromURL(getUrl, delegate: self)
        if connection == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network connection failed")
        } else {
            self.currentPage!++
            self.indexOfCurrentHttpRequest = .GetNextPageResults
            self.HUD = Toolbox.setupCustomProcessingViewWithTitle(title: nil)
        }
        connection = nil
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
                self.indexOfCurrentHttpRequest = .DeleteSchedule
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
        
        if self.indexOfCurrentHttpRequest == .DeleteSchedule {  // http request to delete schedule
            let responseStr = NSString(data: self.responseData!, encoding: NSUTF8StringEncoding)
            if responseStr == "OK" {
                Toolbox.showCustomAlertViewWithImage("checkmark", title: "Schedule deleted successfully")
                self.schedules.removeAtIndex(self.deletingScheduleIndex!)
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: self.deletingScheduleIndex!, inSection: 0)], withRowAnimation: .Right)
            } else {
                Toolbox.showCustomAlertViewWithImage("unhappy", title: "\(responseStr!)")
            }
        } else {    // http request to get next page of schedules
            let responseDictionary = (try? NSJSONSerialization.JSONObjectWithData(self.responseData!, options: .MutableLeaves)) as? [String: AnyObject]
            self.responseData = nil
            self.responseData = NSMutableData()
            
            if responseDictionary == nil {
                Toolbox.showCustomAlertViewWithImage("unhappy", title: "Filter failed")
            } else {
                self.totalResults = responseDictionary!["paginationInfo"]!["total"] as? Int
                let models = responseDictionary!["models"] as? [[String: String]]
                if self.totalResults == 0 || models == nil {
                    Toolbox.showCustomAlertViewWithImage("unhappy", title: "No filter result")
                } else {
                    for scheduleModel in models! {
                        let scheduleObject = Schedule(data: scheduleModel)
                        self.schedules.append(scheduleObject)
                    }
                    if self.schedules.count == self.totalResults {
                        // no more results, should remove the next page button at table view footer
                        self.tableView.tableFooterView = UIView(frame: CGRectZero)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
}
