//
//  FilterScheduleTableViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class FilterScheduleTableViewController: UITableViewController, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
    
    var button_filter: UIButton?
    var fromDate: NSDate?
    var toDate: NSDate?
    var HUD: MBProgressHUD?
    var responseData: NSMutableData? = NSMutableData()
    var filterScheduleResults: [Schedule]? = [Schedule]()
    var totalFilterResults: Int?

    @IBOutlet weak var tableCell_fromDate: UITableViewCell!
    @IBOutlet weak var tableCell_toDate: UITableViewCell!
    @IBOutlet weak var label_fromDate: UILabel!
    @IBOutlet weak var label_toDate: UILabel!
    
    deinit {
        self.fromDate = nil
        self.toDate = nil
        self.button_filter = nil
        self.HUD = nil
        self.responseData = nil
        if self.filterScheduleResults != nil {
            self.filterScheduleResults?.removeAll()
            self.filterScheduleResults = nil
        }
        self.totalFilterResults = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 70))

        if section == 0 {   // add button to the footer of table section
            self.button_filter = Appearance.setupTableFooterButtonWithTitle("Filter", backgroundColor: ColorSettledGreen)
            self.button_filter?.addTarget(self, action: "filterSchedule", forControlEvents: .TouchUpInside)
            footerView.addSubview(self.button_filter!)
            
            Toolbox.toggleButton(self.button_filter!, enabled: false)
        }
        return footerView
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let currentTime = NSDate()
        if indexPath.row == 0 {                 // setting up date range from date
            var maximumDate: NSDate? = nil
            if self.toDate != nil {
                maximumDate = self.toDate
            }
            let actionSheetDatePicker = ActionSheetDatePicker(title: "Date range from -", datePickerMode: .Date, selectedDate: currentTime, minimumDate: nil, maximumDate: maximumDate, target: self, action: "fromDateSelected:", origin: self.tableCell_fromDate)
            actionSheetDatePicker.hideCancel = false
            actionSheetDatePicker.showActionSheetPicker()
        } else if indexPath.row == 1 {          // setting up date range to date
            var minimumDate: NSDate? = nil
            if self.fromDate != nil {
                minimumDate = self.fromDate
            }
            let actionSheetDatePicker = ActionSheetDatePicker(title: "Date range to -", datePickerMode: .Date, selectedDate: currentTime, minimumDate: minimumDate, maximumDate: nil, target: self, action: "toDateSelected:", origin: self.tableCell_fromDate)
            actionSheetDatePicker.hideCancel = false
            actionSheetDatePicker.showActionSheetPicker()
        }
    }
    
    func fromDateSelected(selectedDate: NSDate) {
        self.fromDate = selectedDate
        self.label_fromDate.text = self.fromDate?.getDateString()
        self.validateUserInput()
    }
    
    func toDateSelected(selectedDate: NSDate) {
        self.toDate = selectedDate
        self.label_toDate.text = self.toDate?.getDateString()
        self.validateUserInput()
    }
    
    func validateUserInput() {
        if self.fromDate != nil && self.toDate != nil {
            Toolbox.toggleButton(self.button_filter!, enabled: true)
        } else {
            Toolbox.toggleButton(self.button_filter!, enabled: false)
        }
    }
    
    func filterSchedule() {
        let getUrl = "\(URLFilterSchedules)?startTime=\(self.label_fromDate.text!)&endTime=\(self.label_toDate.text!)"
        var connection = Toolbox.asyncHttpGetFromURL(getUrl, delegate: self)
        if connection == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network connection failed")
        } else {
            self.HUD = Toolbox.setupCustomProcessingViewWithTitle(title: nil)
        }
        connection = nil
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
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Filter failed")
            return
        }
        self.totalFilterResults = responseDictionary!["total"]?.integerValue
        let models = responseDictionary!["models"] as? [[String: String]]
        if self.totalFilterResults == 0 || models == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "No filter result")
            return
        }
        self.filterScheduleResults?.removeAll()
        for scheduleModel in models! {
            let scheduleObject = Schedule(data: scheduleModel)
            self.filterScheduleResults?.append(scheduleObject)
        }
        self.performSegueWithIdentifier("filterResultsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "filterResultsSegue" {
            let destinationViewController = segue.destinationViewController as! ScheduleResultsTableViewController
            destinationViewController.schedules = self.filterScheduleResults!
        }
    }

}
