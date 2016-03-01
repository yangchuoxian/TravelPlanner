//
//  Singleton_CurrentUser.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/28.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class Singleton_CurrentUser: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    static let sharedInstance = Singleton_CurrentUser()
    
    var userId = ""
    var username = ""
    var email = ""
    var phoneNumber = ""
    var name = ""
    var citizenID = ""
    
    var HUD: MBProgressHUD?
    var currentUpdatingInfoName: String?
    var updatedUserInfoValue = ""
    var responseData: NSMutableData? = NSMutableData()
    
    func getUserInfoFrom(userInfo: [NSObject: AnyObject]) {
        self.userId = userInfo["id"] as! String
        NSUserDefaults.standardUserDefaults().setObject(self.userId, forKey: "currentUserId")
        self.username = userInfo["username"] as! String
        if let email = userInfo["email"] as? String {
            self.email = email
        }
        if let phoneNumber = userInfo["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        }
        if let name = userInfo["name"] as? String {
            self.name = name
        }
        if let citizenID = userInfo["citizenID"] as? String {
            self.citizenID = citizenID
        }
    }
    
    func resetCurrentUserInfo() {
        self.userId = ""
        self.username = ""
        self.email = ""
        self.phoneNumber = ""
        self.name = ""
        self.citizenID = ""
    }
    
    func updateUserInfo(infoName: String, infoValue: AnyObject) {
        self.updatedUserInfoValue = infoValue as! String
        self.currentUpdatingInfoName = infoName
        let connection = Toolbox.asyncHttpPostToURL(URLUpdateUser, parameters: "\(infoName)=\(infoValue as! String)&id=\(self.userId)", delegate: self)
        if connection == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network connection failed")
        } else {
            self.HUD = Toolbox.setupCustomProcessingViewWithTitle(title: nil)
        }
    }
    
    func updateUserPassword(oldPassword: String, newPassword: String, confirmPassword: String) {
        let postParamsString = "oldPassword=\(oldPassword)&newPassword=\(newPassword)&confirmPassword=\(confirmPassword)&id=\(self.userId)"
        let connection = Toolbox.asyncHttpPostToURL(URLChangeUserPassword, parameters: postParamsString, delegate: self)
        
        self.currentUpdatingInfoName = "password"
        self.updatedUserInfoValue = newPassword
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
        if responseStr == "OK" {    // user info successfully updated
            if self.currentUpdatingInfoName == "username" {
                self.username = self.updatedUserInfoValue
            } else if self.currentUpdatingInfoName == "email" {
                self.email = self.updatedUserInfoValue
            } else if self.currentUpdatingInfoName == "phoneNumber" {
                self.phoneNumber = self.updatedUserInfoValue
            } else if self.currentUpdatingInfoName == "name" {
                self.name = self.updatedUserInfoValue
            } else if self.currentUpdatingInfoName == "citizenID" {
                self.citizenID = self.updatedUserInfoValue
            }
            // notify that user info updated successfully
            NSNotificationCenter.defaultCenter().postNotificationName("userInfoUpdated", object: ["userInfoIndex": self.currentUpdatingInfoName!])
        } else {                    // user info update failed
            Toolbox.showCustomAlertViewWithImage("unhappy", title: (responseStr as! String))
        }
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
    func logout() {
        // remove the login credentials saved in keychain
        let keychainItem = KeychainItemWrapper(identifier: "TravelPlannerLogin", accessGroup: nil)
        keychainItem.resetKeychainItem()
        // reset existing currentUser instance value
        self.resetCurrentUserInfo()
        // change rootViewController to loginViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("accountNavigationViewController")
        UIApplication.sharedApplication().keyWindow?.rootViewController = rootViewController
    }
    
    func processUserLogin(userJSON: [NSObject: AnyObject]) {
        // save user info to singleton currentUser instance
        Singleton_CurrentUser.sharedInstance.getUserInfoFrom(userJSON)
        // store username and login token in keychain
        let loginToken = userJSON["loginToken"] as? String
        if Toolbox.isStringValueValid(loginToken) {
            Toolbox.saveUserCredential(Singleton_CurrentUser.sharedInstance.userId, loginToken: (userJSON["loginToken"] as! String))
        }
        // remember the user with id as last login user in userDefaults, so as to show his/her avatar in loginViewController
        NSUserDefaults.standardUserDefaults().setObject(self.userId, forKey: "lastLoginUserId")
        
        // change rootViewController to mainTabBarViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController")
        if UIApplication.sharedApplication().keyWindow != nil {
            UIApplication.sharedApplication().keyWindow!.rootViewController = rootViewController
        } else {
            UIApplication.sharedApplication().delegate?.window??.rootViewController = rootViewController
        }
    }
    
}
