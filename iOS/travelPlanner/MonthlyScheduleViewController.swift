//
//  MonthlyScheduleViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class MonthlyScheduleViewController: UIViewController, JTCalendarDataSource, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
    
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var calendarContentView: JTCalendarContentView!
    
    var calendar: JTCalendar!
    var selectedDate: NSDate?
    var HUD: MBProgressHUD?
    var responseData: NSMutableData? = NSMutableData()
    var schedules: [Schedule]? = [Schedule]()
    var scheduleDate = [String]()
    var startDateRangeOfCurrentBatch: NSDate?
    var endDateRangeOfCurrentBatch: NSDate?
    
    deinit {
        if self.calendar != nil {
            self.calendar.dataSource = nil
            self.calendar.menuMonthsView = nil
            self.calendar.contentView = nil
            self.calendar = nil
        }
        self.selectedDate = nil
        self.HUD = nil
        self.responseData = nil
        if self.schedules != nil {
            self.schedules?.removeAll()
            self.schedules = nil
        }
        self.scheduleDate.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up and show JTCalendar
        self.calendar = JTCalendar()
        self.calendar.calendarAppearance.ratioContentMenu = 0.5
        self.calendar.menuMonthsView = self.calendarMenuView
        self.calendar.contentView = self.calendarContentView
        // for calendar menu title, show year and month instead of just month by default
        self.calendar.calendarAppearance.monthBlock = {
            date, jtCalendar in
            let dateComponents = date.getDateComponents()
            return "\(dateComponents.year)年\(dateComponents.month)月"
        }
        self.calendar.dataSource = self
        
        self.getSchedulesForRecentMonthsFromServer()
        
        // listen to notification of new schedule creation
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showCreatedSchedule:", name: "scheduleCreated", object: nil)
    }
    
    func showCreatedSchedule(notification: NSNotification) {
        let createdSchedule = notification.object as! Schedule
        self.schedules?.append(createdSchedule)
        self.scheduleDate.append(createdSchedule.startDate)
        self.calendar.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func calendarHaveEvent(calendar: JTCalendar!, date: NSDate!) -> Bool {
        let dateString = date.getDateString()
        if self.scheduleDate.contains(dateString) {
            // there is at least one schedule on this date
            return true
        }
        // No schedule on this date
        return false
    }
    
    func calendarDidDateSelected(calendar: JTCalendar!, date: NSDate!) {
        self.selectedDate = date
        if self.scheduleDate.contains(self.selectedDate!.getDateString()) {
            self.performSegueWithIdentifier("scheduleResultsSegue", sender: self)
        } else {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "No schedule on this date")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scheduleResultsSegue" {
            // get all schedules on selected date
            var schedulesOnSelectedDate = [Schedule]()
            if self.schedules != nil {
                for scheduleObject in self.schedules! {
                    if scheduleObject.startDate == self.selectedDate!.getDateString() {
                        schedulesOnSelectedDate.append(scheduleObject)
                    }
                }
            }
            let destinationViewController = segue.destinationViewController as! ScheduleResultsTableViewController
            destinationViewController.totalResults = schedulesOnSelectedDate.count
            destinationViewController.schedules = schedulesOnSelectedDate
        }
    }
    
    func calendarDidLoadPreviousPage() {
        self.getSchedulesForRecentMonthsFromServer()
    }
    
    func calendarDidLoadNextPage() {
        self.getSchedulesForRecentMonthsFromServer()
    }
    
    func getSchedulesForRecentMonthsFromServer() {
        let date = self.calendar.currentDate!
        let month = date.getDateComponents().month
        let year = date.getDateComponents().year
        
        var startTime: String
        var endTime: String
        if month == 1 {
            // if the current month is January, the last month should be December of the PREVIOUS YEAR
            startTime = "\(Int(year - 1))-12-15"
            endTime = "\(Int(year))-" + "\(Int(month + 1))-15"
        } else if month == 12 {
            // if the current month is December, the next month should be January of the NEXT YEAR
            startTime = "\(Int(year))-\(Int(month - 1))-15"
            endTime = "\(Int(year + 1))-01-15"
        } else {
            startTime = "\(Int(year))-\(Int(month - 1))-15"
            endTime = "\(Int(year))-\(Int(month + 1))-15"
        }
        
        self.startDateRangeOfCurrentBatch = NSDate(dateString: startTime)
        self.endDateRangeOfCurrentBatch = NSDate(dateString: endTime)
        
        let getUrl = "\(URLFilterSchedules)?startTime=\(startTime)&endTime=\(endTime)"
        let connection = Toolbox.asyncHttpGetFromURL(getUrl, delegate: self)
        if connection == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network")
        } else {
            self.HUD = Toolbox.setupCustomProcessingViewWithTitle(title: nil)
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
        
        let responseDictionary = (try? NSJSONSerialization.JSONObjectWithData(self.responseData!, options: .MutableLeaves)) as? [String: AnyObject]
        self.responseData = nil
        self.responseData = NSMutableData()
        
        if responseDictionary == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Get schedules failed")
            return
        }
        let models = responseDictionary!["models"] as? [[String: String]]
        
        self.scheduleDate.removeAll()
        self.schedules?.removeAll()
        
        for scheduleModel in models! {
            let scheduleObject = Schedule(data: scheduleModel)
            self.schedules?.append(scheduleObject)
            self.scheduleDate.append(scheduleObject.startDate)
        }
        self.calendar.reloadData()
    }

}
