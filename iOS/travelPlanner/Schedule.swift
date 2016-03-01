//
//  Schedule.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class Schedule: NSObject {
    var scheduleId = ""
    var cityOfDeparture = ""
    var cityOfArrival = ""
    var startDate = ""
    var endDate = ""
    var username = ""
    var comment = ""
    
    init(data: [String: String]) {
        self.scheduleId = data["id"]!
        self.cityOfDeparture = data["cityOfDeparture"]!
        self.cityOfArrival = data["cityOfArrival"]!
        self.startDate = data["startDate"]!
        if Toolbox.isDateStringServerDateFormat(self.startDate) {
            let startDateObject = NSDate(dateTimeString: self.startDate)
            self.startDate = startDateObject.getDateString()
        }
        self.endDate = data["endDate"]!
        if Toolbox.isDateStringServerDateFormat(self.endDate) {
            let endDateObject = NSDate(dateTimeString: self.endDate)
            self.endDate = endDateObject.getDateString()
        }
        self.username = data["username"]!
        self.comment = data["comment"]!
    }
}
