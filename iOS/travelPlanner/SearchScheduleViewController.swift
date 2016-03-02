//
//  SearchScheduleViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class SearchScheduleViewController: UIViewController, UITextFieldDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate {

    @IBOutlet weak var input_search: UITextField!
    @IBOutlet weak var button_search: UIButton!
    
    var HUD: MBProgressHUD?
    var responseData: NSMutableData? = NSMutableData()
    var totalSearchResults: Int?
    var searchScheduleResults: [Schedule]? = [Schedule]()
    
    deinit {
        self.HUD = nil
        self.responseData = nil
        self.totalSearchResults = nil
        if self.searchScheduleResults != nil {
            self.searchScheduleResults?.removeAll()
            self.searchScheduleResults = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Appearance.customizeTextField(self.input_search, iconName: "search")
        
        self.input_search.delegate = self
        self.input_search.addTarget(self, action: "validateUserInput", forControlEvents: .EditingChanged)
        
        Toolbox.toggleButton(self.button_search, enabled: false)
        self.button_search.layer.cornerRadius = 2.0
    }
    
    func validateUserInput() {
        let enteredSearchKeywordLength = Toolbox.trim(self.input_search.text!).characters.count
        if enteredSearchKeywordLength > 0 {
            Toolbox.toggleButton(self.button_search, enabled: true)
        } else {
            Toolbox.toggleButton(self.button_search, enabled: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.input_search.resignFirstResponder()
    }
    
    @IBAction func submitSearch(sender: AnyObject) {
        self.input_search.resignFirstResponder()
        var connection = Toolbox.asyncHttpGetFromURL("\(URLSearchSchedules)?keyword=\(Toolbox.trim(self.input_search.text!))", delegate: self)
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
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Search failed")
            return
        }
        self.totalSearchResults = responseDictionary!["paginationInfo"]!["total"] as? Int
        let models = responseDictionary!["models"] as? [[String: String]]
        if self.totalSearchResults == 0 || models == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "No search result")
            return
        }
        self.searchScheduleResults?.removeAll()
        for scheduleModel in models! {
            let scheduleObject = Schedule(data: scheduleModel)
            self.searchScheduleResults?.append(scheduleObject)
        }
        self.performSegueWithIdentifier("searchResultsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchResultsSegue" {
            let destinationViewController = segue.destinationViewController as! ScheduleResultsTableViewController
            destinationViewController.scheduleResultType = .SearchResult
            destinationViewController.totalResults = self.totalSearchResults
            destinationViewController.searchKeyword = Toolbox.trim(self.input_search.text!)
            destinationViewController.schedules = self.searchScheduleResults!
        }
    }
    
}
