//
//  NewScheduleTableViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class NewScheduleTableViewController: UITableViewController, UITextViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var button_createNewSchedule: UIButton?
    var HUD: MBProgressHUD?
    var responseData: NSMutableData? = NSMutableData()

    @IBOutlet weak var label_cityOfDeparture: UILabel!
    @IBOutlet weak var label_cityOfArrival: UILabel!
    @IBOutlet weak var label_startDate: UILabel!
    @IBOutlet weak var label_endDate: UILabel!
    @IBOutlet weak var textView_comment: UITextView!
    
    deinit {
        self.button_createNewSchedule = nil
        self.HUD = nil
        self.responseData = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        self.textView_comment.delegate = self
        // set up the create button for table footer
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 70))
        self.button_createNewSchedule = Appearance.setupTableFooterButtonWithTitle("Create", backgroundColor: ColorPrimaryBlue)
        self.button_createNewSchedule?.addTarget(self, action: "submitNewSchedule", forControlEvents: .TouchUpInside)
        footerView.addSubview(self.button_createNewSchedule!)
        
        Toolbox.toggleButton(self.button_createNewSchedule!, enabled: false)
        
        self.tableView.tableFooterView = footerView
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "cancelCreatingSchedule")
    }
    
    func cancelCreatingSchedule() {
        self.performSegueWithIdentifier("cancelNewScheduleSegue", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Appearance.customizeNavigationBar(self, title: "New schedule")
    }
    
    func validateUserInput() {
        // if all field but comment have values, then enable the create button to allow creating schedule
        if self.label_cityOfDeparture.text?.characters.count > 0 &&
        self.label_cityOfArrival.text?.characters.count > 0 &&
        self.label_startDate.text?.characters.count > 0 &&
        self.label_endDate.text?.characters.count > 0 &&
        self.textView_comment.text?.characters.count <= 500 {
            Toolbox.toggleButton(self.button_createNewSchedule!, enabled: true)
        } else {
            Toolbox.toggleButton(self.button_createNewSchedule!, enabled: false)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {         // change departure city
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
                })
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {         // change start date
                var maximumDate: NSDate? = nil
                if self.label_endDate.text?.characters.count > 0 {
                    maximumDate = NSDate(dateString: self.label_endDate.text!)
                }
                let actionSheetDatePicker = ActionSheetDatePicker(title: "Start date", datePickerMode: .Date, selectedDate: NSDate(), minimumDate: NSDate(), maximumDate: maximumDate, target: self, action: "changeStartDateTo:", origin: self.tableView.cellForRowAtIndexPath(indexPath))
                actionSheetDatePicker.hideCancel = false
                actionSheetDatePicker.showActionSheetPicker()
            } else if indexPath.row == 1 {  // change end date
                var minimumDate = NSDate()
                if self.label_startDate.text?.characters.count > 0 {
                    minimumDate = NSDate(dateString: self.label_startDate.text!)
                }
                let actionSheetDatePicker = ActionSheetDatePicker(title: "End date", datePickerMode: .Date, selectedDate: NSDate(), minimumDate: minimumDate, maximumDate: nil, target: self, action: "changeEndDateTo:", origin: self.tableView.cellForRowAtIndexPath(indexPath))
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.textView_comment.resignFirstResponder()
        }
        self.validateUserInput()
        return true
    }
    
    func submitNewSchedule() {
        let cityOfDeparture = self.label_cityOfDeparture.text!
        let cityOfArrival = self.label_cityOfArrival.text!
        let startDate = self.label_startDate.text!
        let endDate = self.label_endDate.text!
        let comment = self.textView_comment.text!
        
        let postParams = "cityOfDeparture=\(cityOfDeparture)&cityOfArrival=\(cityOfArrival)&startDate=\(startDate)&endDate=\(endDate)&comment=\(comment)"
        let connection = Toolbox.asyncHttpPostToURL(URLCreateNewSchedule, parameters: postParams, delegate: self)
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
        
        let responseDictionary = (try? NSJSONSerialization.JSONObjectWithData(self.responseData!, options: .MutableLeaves)) as? [String: String]
        
        if responseDictionary == nil {
            let responseStr = NSString(data: self.responseData!, encoding: NSUTF8StringEncoding)
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "\(responseStr!)")
        } else {
            Toolbox.showCustomAlertViewWithImage("checkmark", title: "Create new schedule succeeded")
            // clear user input
            self.label_cityOfDeparture.text = ""
            self.label_cityOfArrival.text = ""
            self.label_startDate.text = ""
            self.label_endDate.text = ""
            self.textView_comment.text = ""
            let createdSchedule = Schedule(data: responseDictionary!)
            // notify that a new schedule is created
            NSNotificationCenter.defaultCenter().postNotificationName("scheduleCreated", object: createdSchedule)
        }
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
}
