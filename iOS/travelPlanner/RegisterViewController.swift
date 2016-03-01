//
//  RegisterViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/28.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var input_username: UITextField!
    @IBOutlet weak var input_password: UITextField!
    @IBOutlet weak var input_email: UITextField!
    @IBOutlet weak var button_register: UIButton!
    @IBOutlet weak var image_avatar: UIImageView!
    
    var picker: UIImagePickerController?
    var HUD: MBProgressHUD?
    var userId: String?
    var currentActiveTextFieldIndex: Int?
    var indexOfCurrentHttpRequest: httpRequest?
    var responseData: NSMutableData? = NSMutableData()
    
    enum httpRequest {
        case UploadAvatar
        case SubmitNewUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Appearance.customizeAvatarImage(self.image_avatar)
        Appearance.customizeTextField(self.input_username, iconName: "person")
        Appearance.customizeTextField(self.input_password, iconName: "locked")
        Appearance.customizeTextField(self.input_email, iconName: "at")
        
        self.button_register.layer.cornerRadius = 2.0
        // add tap gesture event to image_avatar, when image_avatar is tapped, user will be provided with options to whether select image or shoot a photo as avatar to upload
        let singleTap = UITapGestureRecognizer(target: self, action: "avatarImageTapped")
        singleTap.numberOfTapsRequired = 1
        
        self.image_avatar.userInteractionEnabled = true
        self.image_avatar.addGestureRecognizer(singleTap)
        // assign tag value for different textField so that the system knows which textField is active/being edited
        self.input_username.tag = TagValue.TextFieldUsername.rawValue
        self.input_password.tag = TagValue.TextFieldPassword.rawValue
        self.input_email.tag = TagValue.TextFieldEmail.rawValue
        
        self.input_username.delegate = self
        self.input_password.delegate = self
        self.input_email.delegate = self
        
        // add tap gesture for scrollView to hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        self.scrollView.addGestureRecognizer(gestureRecognizer)
        self.input_username.addTarget(self, action: "validateUserInput", forControlEvents: .EditingChanged)
        self.input_password.addTarget(self, action: "validateUserInput", forControlEvents: .EditingChanged)
        self.input_email.addTarget(self, action: "validateUserInput", forControlEvents: .EditingChanged)
    }
    
    func validateUserInput() {
        let enteredUsernameLength = Toolbox.trim(self.input_username.text!).characters.count
        let enteredPasswordLength = Toolbox.trim(self.input_password.text!).characters.count
        let enteredEmail = Toolbox.trim(self.input_email.text!)
        let enteredEmailLength = Toolbox.trim(enteredEmail).characters.count
        
        if enteredUsernameLength > 0 && enteredUsernameLength <= 80 &&
            enteredPasswordLength >= 6 && enteredPasswordLength <= 20 &&
            enteredEmailLength > 0 && enteredEmailLength < 100 &&
            Toolbox.isValidEmail(enteredEmail) {
                Toolbox.toggleButton(self.button_register, enabled: true)
        } else {
            Toolbox.toggleButton(self.button_register, enabled: false)
        }
    }
    
    func hideKeyboard(sender: AnyObject) {
        // hide keyboard
        self.input_username.resignFirstResponder()
        self.input_password.resignFirstResponder()
        self.input_email.resignFirstResponder()
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {   // cancel button clicked
            return
        }
        // release self.picker memory first
        if self.picker != nil {
            self.picker?.delegate = nil
        }
        self.picker = nil

        self.picker = UIImagePickerController()
        self.picker?.delegate = self
        self.picker?.allowsEditing = true
        
        if buttonIndex == 1 {   // choose image from gallery
            self.picker?.sourceType = .PhotoLibrary
        } else if buttonIndex == 2 {    // take a photo
            self.picker?.sourceType = .Camera
        }
        self.presentViewController(self.picker!, animated: true, completion: nil)
    }
    
    func avatarImageTapped() {
        let selectPhoto = "Choose photo"
        let takePhoto = "Shoot photo"
        let cancelTitle = "Cancel"
        let actionSheet: UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil, otherButtonTitles: selectPhoto, takePhoto)
        actionSheet.showInView(self.view)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.currentActiveTextFieldIndex = textField.tag
    }
    
    // called when the UIKeyboardDidShowNotification is sent
    func keyboardWasShown(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        // if active text field is hidden by keyboard, scroll it so it's visible
        let tempRect: CGRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + (ToolbarHeight + NavigationbarHeight), width: self.view.frame.size.width, height: self.view.frame.size.height - keyboardSize.height - (ToolbarHeight + NavigationbarHeight))
        var activeField: UITextField?
        switch self.currentActiveTextFieldIndex! {
        case TagValue.TextFieldUsername.rawValue:
            activeField = self.input_username
            break
        case TagValue.TextFieldPassword.rawValue:
            activeField = self.input_password
            break
        case TagValue.TextFieldEmail.rawValue:
            activeField = self.input_email
            break
        default:
            activeField = nil
            break
        }
        if !CGRectContainsPoint(tempRect, activeField!.frame.origin) {
            self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }
    
    // called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: ToolbarHeight + NavigationbarHeight, left: 0, bottom: 0, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.input_username {
            self.input_username.resignFirstResponder()
            self.input_password.becomeFirstResponder()
            return true
        } else if textField == self.input_password {
            self.input_password.resignFirstResponder()
            self.input_email.becomeFirstResponder()
            return true
        } else if textField == self.input_email {
            if self.button_register.enabled {
                self.input_email.resignFirstResponder()
                self.button_register.sendActionsForControlEvents(.TouchUpInside)
                return true
            }
            return false
        }
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        Appearance.customizeNavigationBar(self, title: "User Registration")
        // register for keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if self.picker != nil {
            self.picker?.delegate = nil
        }
        self.picker = nil
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.image_avatar.image = image
        self.uploadAvatar(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if self.picker != nil {
            self.picker?.delegate = nil
        }
        self.picker = nil
    }
    
    func uploadAvatar(image: UIImage) {
        var connection: NSURLConnection?
        if Toolbox.isStringValueValid(self.userId) {    // self.userId defined, meaning user avatar is already uploaded, temporary user already generated in server database
            connection = Toolbox.uploadImageToURL(URLUploadUserAvatar, image: image, parameters: ["modelId": self.userId!], delegate: self)
        } else {
            connection = Toolbox.uploadImageToURL(URLUploadUserAvatar, image: image, parameters: nil, delegate: self)
        }
        if connection == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network connection failed")
        } else {
            self.indexOfCurrentHttpRequest = .UploadAvatar
            self.HUD = MBProgressHUD(view: self.navigationController?.view)
            self.navigationController?.view.addSubview(self.HUD!)
            self.HUD?.show(true)
        }
        connection = nil
    }
    
    @IBAction func submitNewUser(sender: AnyObject) {
        let username = Toolbox.trim(self.input_username.text!)
        let password = Toolbox.trim(self.input_password.text!)
        let email = Toolbox.trim(self.input_email.text!)
        
        var postParamsString: String
        if Toolbox.isStringValueValid(self.userId) {
            postParamsString = "username=\(username)&password=\(password)&email=\(email)&id=\(self.userId!)"
        } else {    // self.userId not defined, meaning user avatar is NOT uploaded
            postParamsString = "username=\(username)&password=\(password)&email=\(email)"
        }
        let connection = Toolbox.asyncHttpPostToURL(URLSubmitNewUser, parameters: postParamsString, delegate: self)
        if connection == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "网络连接失败")
        } else {
            self.indexOfCurrentHttpRequest = .SubmitNewUser
            self.HUD = Toolbox.setupCustomProcessingViewWithTitle(title: nil)
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.responseData?.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.HUD!.hide(true)
        self.HUD = nil
        Toolbox.showCustomAlertViewWithImage("unhappy", title: "Request failed")
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.HUD!.hide(true)
        self.HUD = nil
        
        let responseStr = NSString(data: self.responseData!, encoding: NSUTF8StringEncoding)
        if self.indexOfCurrentHttpRequest == .UploadAvatar {
            // response for user avatar upload
            // retrieve user id from json data
            let jsonArray = (try? NSJSONSerialization.JSONObjectWithData(self.responseData!, options: .MutableLeaves)) as? NSDictionary
            self.userId = jsonArray!.objectForKey("modelId") as? String
            if self.userId != nil {     // upload new user avatar succeeded
                // save successfully uploaded user avatar to local app directory
                Toolbox.saveAvatarImageLocally(self.image_avatar.image!, modelId: self.userId!)
            } else {                    // upload new user avatar failed
                Toolbox.showCustomAlertViewWithImage("unhappy", title: "Upload user avatar failed")
            }
        } else {    // response for new user registration
            // if registration succeeded, response from server should be user info JSON data, so retrieve username from this JSON data to see if registration is successful
            let userJSON = (try? NSJSONSerialization.JSONObjectWithData(self.responseData!, options: .MutableLeaves)) as? [NSObject: AnyObject]
            let respondedUsername = userJSON?["username"] as? String
            if respondedUsername != nil {   // submit new user succeeded
                Singleton_CurrentUser.sharedInstance.processUserLogin(userJSON!)
            } else {    // submit new user failed with error message
                Toolbox.showCustomAlertViewWithImage("unhappy", title: responseStr as! String)
            }
        }
        
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
    deinit {
        self.image_avatar.image = nil
        if self.picker != nil {
            self.picker?.delegate = nil
            self.picker = nil
        }
        self.HUD = nil
        self.userId = nil
        self.currentActiveTextFieldIndex = nil
        self.indexOfCurrentHttpRequest = nil
        self.responseData = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
