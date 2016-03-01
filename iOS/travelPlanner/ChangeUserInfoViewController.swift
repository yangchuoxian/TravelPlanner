//
//  ChangeUserInfoViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class ChangeUserInfoViewController: UIViewController {

    var currentUserInfo: UserInfo?
    
    @IBOutlet weak var input_userInfo: UITextField!
    @IBOutlet weak var button_submit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var viewControllerTitle = ""
        var placeholderText = ""
        var inputFieldText = ""
        var iconName = ""
        if self.currentUserInfo == .Username {
            viewControllerTitle = "Change username"
            placeholderText = "Enter username"
            inputFieldText = Singleton_CurrentUser.sharedInstance.username
            iconName = "person"
            self.input_userInfo.keyboardType = .Default
        } else if self.currentUserInfo == .Email {
            viewControllerTitle = "Change email"
            placeholderText = "Enter email"
            inputFieldText = Singleton_CurrentUser.sharedInstance.email
            iconName = "at"
            self.input_userInfo.keyboardType = .EmailAddress
        } else if self.currentUserInfo == .Phone {
            viewControllerTitle = "Change phone"
            placeholderText = "Enter phone"
            inputFieldText = Singleton_CurrentUser.sharedInstance.phoneNumber
            iconName = "phone"
            self.input_userInfo.keyboardType = .PhonePad
        } else if self.currentUserInfo == .Name {
            viewControllerTitle = "Change name"
            placeholderText = "Enter name"
            inputFieldText = Singleton_CurrentUser.sharedInstance.name
            iconName = "name"
            self.input_userInfo.keyboardType = .Default
        } else if self.currentUserInfo == .CitizenId {
            viewControllerTitle = "Change citizen ID"
            placeholderText = "Enter citizen ID"
            inputFieldText = Singleton_CurrentUser.sharedInstance.citizenID
            iconName = "file"
            self.input_userInfo.keyboardType = .NumberPad
        }
        
        Appearance.customizeTextField(self.input_userInfo, iconName: iconName)
        Appearance.customizeNavigationBar(self, title: viewControllerTitle)
        self.input_userInfo.text = inputFieldText
        self.input_userInfo.placeholder = placeholderText
        
        self.input_userInfo.addTarget(self, action: "validateUserInput", forControlEvents: .EditingChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goBackToUserInfoTableViewController", name: "userInfoUpdated", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validateUserInput() {
        let enteredUserInfo = self.input_userInfo.text!
        let enteredTextLength = Toolbox.trim(enteredUserInfo).characters.count
        if self.currentUserInfo == .Username {
            if enteredTextLength > 0 && enteredTextLength <= 30 {
                Toolbox.toggleButton(self.button_submit, enabled: true)
            } else {
                Toolbox.toggleButton(self.button_submit, enabled: false)
            }
        } else if self.currentUserInfo == .Email {
            if Toolbox.isValidEmail(enteredUserInfo) {
                Toolbox.toggleButton(self.button_submit, enabled: true)
            } else {
                Toolbox.toggleButton(self.button_submit, enabled: false)
            }
        } else if self.currentUserInfo == .Phone {
            if enteredTextLength == 10 {
                Toolbox.toggleButton(self.button_submit, enabled: true)
            } else {
                Toolbox.toggleButton(self.button_submit, enabled: false)
            }
        } else if self.currentUserInfo == .Name {
            if enteredTextLength > 0 && enteredTextLength <= 50 {
                Toolbox.toggleButton(self.button_submit, enabled: true)
            } else {
                Toolbox.toggleButton(self.button_submit, enabled: false)
            }
        } else if self.currentUserInfo == .CitizenId {
            if enteredTextLength > 0 && enteredTextLength <= 30 {
                Toolbox.toggleButton(self.button_submit, enabled: true)
            } else {
                Toolbox.toggleButton(self.button_submit, enabled: false)
            }
        }
    }
    
    func goBackToUserInfoTableViewController() {
        // unwind navigation controller to the previous view controller
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.input_userInfo.resignFirstResponder()
    }

    @IBAction func submitUpdatedUserInfo(sender: AnyObject) {
        let userInput = self.input_userInfo.text!
        if self.currentUserInfo == .Username {
            Singleton_CurrentUser.sharedInstance.updateUserInfo("username", infoValue: userInput)
        } else if self.currentUserInfo == .Email {
            Singleton_CurrentUser.sharedInstance.updateUserInfo("email", infoValue: userInput)
        } else if self.currentUserInfo == .Phone {
            Singleton_CurrentUser.sharedInstance.updateUserInfo("phoneNumber", infoValue: userInput)
        } else if self.currentUserInfo == .Name {
            Singleton_CurrentUser.sharedInstance.updateUserInfo("name", infoValue: userInput)
        } else if self.currentUserInfo == .CitizenId {
            Singleton_CurrentUser.sharedInstance.updateUserInfo("citizenID", infoValue: userInput)
        }
        
    }
    
}
