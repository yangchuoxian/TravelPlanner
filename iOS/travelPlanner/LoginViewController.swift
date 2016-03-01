//
//  LoginViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/28.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var input_username: UITextField!
    @IBOutlet weak var input_password: UITextField!
    @IBOutlet weak var button_login: UIButton!
    @IBOutlet weak var imageView_appIconOrLastLoginUserAvatar: UIImageView!
    
    var HUD: MBProgressHUD?
    var username: String?
    var responseData: NSMutableData? = NSMutableData()

    override func viewDidLoad() {
        super.viewDidLoad()

        Appearance.customizeTextField(self.input_username, iconName: "person")
        Appearance.customizeTextField(self.input_password, iconName: "locked")
        
        self.button_login.layer.cornerRadius = 2.0
        // round corner for user avatar image view
        self.imageView_appIconOrLastLoginUserAvatar.layer.cornerRadius = 20.0
        self.imageView_appIconOrLastLoginUserAvatar.clipsToBounds = true
        
        self.input_username.delegate = self
        self.input_password.delegate = self
        self.input_username.addTarget(self, action: "validateUserInput", forControlEvents: .EditingChanged)
        self.input_password.addTarget(self, action: "validateUserInput", forControlEvents: .EditingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validateUserInput() {
        let enteredUsernameLength = Toolbox.trim(self.input_username.text!).characters.count
        let enteredPasswordLength = Toolbox.trim(self.input_password.text!).characters.count
        if enteredUsernameLength > 0 && enteredUsernameLength <= 30 && enteredPasswordLength >= 6 && enteredPasswordLength <= 20 {
            Toolbox.toggleButton(self.button_login, enabled: true)
        } else {
            Toolbox.toggleButton(self.button_login, enabled: false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // resign the keyboard when tapped somewhere else other than the text field or the keyboard itself
        self.input_username.resignFirstResponder()
        self.input_password.resignFirstResponder()
    }
    
    /**
     This function will be called when some input field is focused and the user tapped enter
     
     - parameter textField: the related textField
     
     - returns: should return or not
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.input_username {
            self.input_username.resignFirstResponder()
            self.input_password.becomeFirstResponder()
            return true
        } else if textField == self.input_password {
            if self.button_login.enabled {
                self.input_password.resignFirstResponder()
                self.button_login.sendActionsForControlEvents(.TouchUpInside)
                return true
            }
            return false
        }
        return false
    }
    
    @IBAction func submitLogin(sender: AnyObject) {
        let username = Toolbox.trim(self.input_username.text!)
        let password = Toolbox.trim(self.input_password.text!)
        // save login username
        self.username = username
        let connection = Toolbox.asyncHttpPostToURL(URLSubmitLogin, parameters: "username=\(username)&password=\(password)", delegate: self)
        if connection == nil {
            // inform the user that the connection failed
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network connection failed")
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
        // if login succeeded, response from server should be user info JSON data, so retrieve username from this JSON data to see if login is successful
        let userJSON = (try? NSJSONSerialization.JSONObjectWithData(self.responseData!, options: .MutableLeaves)) as? [NSObject: AnyObject]
        if userJSON != nil {   // login succeeded
            Singleton_CurrentUser.sharedInstance.processUserLogin(userJSON!)
        } else {    // login failed with error message
            let responseStr = NSString(data: self.responseData!, encoding: NSUTF8StringEncoding)
            Toolbox.showCustomAlertViewWithImage("unhappy", title: responseStr! as String)
        }
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
    deinit {
        self.HUD = nil
        self.username = nil
        self.responseData = nil
    }
    
}
