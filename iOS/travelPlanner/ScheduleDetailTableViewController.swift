//
//  ScheduleDetailTableViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class ScheduleDetailTableViewController: UITableViewController, UITextViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var currentSchedule: Schedule?
    var button_changeSchedule: UIButton?
    var HUD: MBProgressHUD?
    var responseData: NSMutableData? = NSMutableData()
    
    @IBOutlet weak var label_cityOfDeparture: UILabel!
    @IBOutlet weak var label_cityOfArrival: UILabel!
    @IBOutlet weak var label_startDate: UILabel!
    @IBOutlet weak var label_endDate: UILabel!
    @IBOutlet weak var textView_comment: UITextView!
    
    deinit {
        self.currentSchedule = nil
        self.button_changeSchedule = nil
        self.HUD = nil
        self.responseData = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        
        self.label_cityOfDeparture.text = self.currentSchedule!.cityOfDeparture
        self.label_cityOfArrival.text = self.currentSchedule!.cityOfArrival
        let startDate = NSDate(dateString: self.currentSchedule!.startDate)
        self.label_startDate.text = startDate.getDateString()
        let endDate = NSDate(dateString: self.currentSchedule!.endDate)
        self.label_endDate.text = endDate.getDateString()
        self.textView_comment.text = self.currentSchedule!.comment
        
        self.textView_comment.delegate = self
        
        
        
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 70))
        
        self.button_changeSchedule = Appearance.setupTableFooterButtonWithTitle("Update", backgroundColor: ColorPrimaryBlue)
        self.button_changeSchedule?.addTarget(self, action: "updateSchedule", forControlEvents: .TouchUpInside)
        footerView.addSubview(self.button_changeSchedule!)
        
        Toolbox.toggleButton(self.button_changeSchedule!, enabled: false)
        self.tableView.tableFooterView = footerView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Appearance.customizeNavigationBar(self, title: "Schedule detail")
    }
    
    func validateUserInput() {
        // if any of the schedule info has been changed, then enable the update button to allow updating schedule
        let startDate = NSDate(dateString: self.currentSchedule!.startDate)
        let endDate = NSDate(dateString: self.currentSchedule!.endDate)
        if startDate.getDateString() != self.label_startDate.text ||
        endDate.getDateString() != self.label_endDate.text ||
        self.currentSchedule!.cityOfDeparture != self.label_cityOfDeparture.text ||
        self.currentSchedule!.cityOfArrival != self.label_cityOfArrival.text ||
        self.currentSchedule!.comment != self.textView_comment.text {
            Toolbox.toggleButton(self.button_changeSchedule!, enabled: true)
        } else {
            Toolbox.toggleButton(self.button_changeSchedule!, enabled: false)
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.textView_comment.resignFirstResponder()
        }
        self.validateUserInput()
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {     // change departure city
                let alertController = UIAlertController(title: "", message: "Enter departure city", preferredStyle: .Alert)
                let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel) {
                    ACTION in return
                }
                let actionOk = UIAlertAction(title: "Ok", style: .Default) {
                    ACTION in
                    let textField = alertController.textFields?.first as UITextField?
                    let cityOfDeparture = textField?.text
                    if cityOfDeparture == nil || cityOfDeparture?.characters.count == 0 {
                        return
                    }
                    self.label_cityOfDeparture.text = cityOfDeparture
                    self.validateUserInput()
                }
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                alertController.addTextFieldWithConfigurationHandler({
                    (textField: UITextField) in
                    textField.placeholder = "Departure city"
                    textField.keyboardType = .Default
                    textField.text = self.currentSchedule!.cityOfDeparture
                })
                self.presentViewController(alertController, animated: true, completion: nil)
            } else if indexPath.row == 1 {  // change arrival city
                let alertController = UIAlertController(title: "", message: "Enter arrival city", preferredStyle: .Alert)
                let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel) {
                    ACTION in return
                }
                let actionOk = UIAlertAction(title: "Ok", style: .Default) {
                    ACTION in
                    let textField = alertController.textFields?.first as UITextField?
                    let cityOfArrival = textField?.text
                    if cityOfArrival == nil || cityOfArrival?.characters.count == 0 {
                        return
                    }
                    self.label_cityOfArrival.text = cityOfArrival
                    self.validateUserInput()
                }
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                alertController.addTextFieldWithConfigurationHandler({
                    (textField: UITextField) in
                    textField.placeholder = "Arrival city"
                    textField.keyboardType = .Default
                    textField.text = self.currentSchedule!.cityOfArrival
                })
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {             // change start date
                let currentStartDate = NSDate(dateString: self.currentSchedule!.startDate)
                let maximumDate = NSDate(dateString: self.currentSchedule!.endDate)
                let actionSheetDatePicker = ActionSheetDatePicker(title: "Start date", datePickerMode: .Date, selectedDate: currentStartDate, minimumDate: nil, maximumDate: maximumDate, target: self, action: "changeStartDateTo:", origin: self.tableView.cellForRowAtIndexPath(indexPath))
                actionSheetDatePicker.hideCancel = false
                actionSheetDatePicker.showActionSheetPicker()
            } else if indexPath.row == 1 {      // change end date
                let currentEndDate = NSDate(dateString: self.currentSchedule!.endDate)
                let minimumDate = NSDate(dateString: self.currentSchedule!.startDate)
                let actionSheetDatePicker = ActionSheetDatePicker(title: "End date", datePickerMode: .Date, selectedDate: currentEndDate, minimumDate: minimumDate, maximumDate: nil, target: self, action: "changeEndDateTo:", origin: self.tableView.cellForRowAtIndexPath(indexPath))
                actionSheetDatePicker.hideCancel = false
                actionSheetDatePicker.showActionSheetPicker()
            }
        }
    }
    
    func changeStartDateTo(selectedStartDate: NSDate) {
        self.label_startDate.text = selectedStartDate.getDateString()
        self.validateUserInput()
    }
    
    func changeEndDateTo(selectedEndDate: NSDate) {
        self.label_endDate.text = selectedEndDate.getDateString()
        self.validateUserInput()
    }
    
    func updateSchedule() {
        let scheduleId = self.currentSchedule!.scheduleId
        let cityOfDeparture = self.label_cityOfDeparture.text!
        let cityOfArrival = self.label_cityOfArrival.text!
        let startDate = self.label_startDate.text!
        let endDate = self.label_endDate.text!
        let comment = self.textView_comment.text!
        
        let postParams = "id=\(scheduleId)&cityOfDeparture=\(cityOfDeparture)&cityOfArrival=\(cityOfArrival)&startDate=\(startDate)&endDate=\(endDate)&comment=\(comment)"
        let connection = Toolbox.asyncHttpPostToURL(URLChangeSchedule, parameters: postParams, delegate: self)
        if connection == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network connection failed")
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
        
        let responseStr = NSString(data: self.responseData!, encoding: NSUTF8StringEncoding)
        if responseStr == "OK" {        // schedule successfully updated
            Toolbox.showCustomAlertViewWithImage("checkmark", title: "Schedule updated successfully")
            // renew the local currentSchedule object
            self.currentSchedule?.cityOfDeparture = self.label_cityOfDeparture.text!
            self.currentSchedule?.cityOfArrival = self.label_cityOfArrival.text!
            self.currentSchedule?.startDate = self.label_startDate.text!
            self.currentSchedule?.endDate = self.label_endDate.text!
            self.currentSchedule?.comment = self.textView_comment.text!
            // notify that a schedule is updated
            NSNotificationCenter.defaultCenter().postNotificationName("scheduleUpdated", object: self.currentSchedule!)
        } else {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "\(responseStr!)")
        }
        
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
}
