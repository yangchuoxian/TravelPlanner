//
//  Constants.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/28.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

enum ScheduleResultType {
    case FilterResult
    case SearchResult
    case ScheduleForSpecificDate
}

enum TagValue: Int {
    case TextFieldUsername = 1
    case TextFieldPassword = 2
    case TextFieldEmail = 3
    case TextViewPlaceholder = 100
}

/* http status code and parameters*/
enum HttpStatusCode: Int {
    case OK = 200
    case NotFound = 404
}

/* User info entry */
enum UserInfo {
    case Username
    case Email
    case Phone
    case Name
    case CitizenId
}

/**
 Different time intervals
 
 - ImageUploadTimeout: time interval for image upload timeout
 - HttpRequestTimeout: time interval for http request timeout
 */
enum TimeIntervals: NSTimeInterval {
    case ImageUploadTimeout = 10
    case HttpRequestTimeout = 5
}

let ScreenSize = UIScreen.mainScreen().bounds.size

//let BaseUrl = "http://localhost:1337"                 // Local address for local device simulator
//let BaseUrl = "http://192.168.0.102:1337"             // Local Area Address for real iPhone device
let BaseUrl = "http://45.63.49.21:1337"               // Remote server address
let URLSubmitLogin = BaseUrl + "/mobile/submit_login"
let URLUpdateUser = BaseUrl + "/mobile/update_user"
let URLChangeUserPassword = BaseUrl + "/mobile/change_user_password"
let URLUploadUserAvatar = BaseUrl + "/mobile/upload_user_avatar"
let URLSubmitNewUser = BaseUrl + "/mobile/submit_new_user"
let URLUserAvatar = BaseUrl + "/mobile/user_avatar?id="
let URLGetUserInfo = BaseUrl + "/mobile/get_user_info"
let URLLogout = BaseUrl + "/mobile/logout"
let URLFilterSchedules = BaseUrl + "/mobile/filter_schedules"
let URLSearchSchedules = BaseUrl + "/mobile/search_schedules"
let URLChangeSchedule = BaseUrl + "/mobile/change_schedule"
let URLDeleteUserSchedule = BaseUrl + "/mobile/delete_user_schedule"
let URLCreateNewSchedule = BaseUrl + "/mobile/create_new_schedule"

/* iOS control widget size constant */
let ToolbarHeight: CGFloat = 20
let NavigationbarHeight: CGFloat = 44