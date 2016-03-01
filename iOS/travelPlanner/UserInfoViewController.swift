//
//  UserInfoViewController.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/29.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class UserInfoTableViewController: UITableViewController, NSURLConnectionDataDelegate, NSURLConnectionDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var HUD: MBProgressHUD?
    var responseData: NSMutableData? = NSMutableData()
    var selectedUserInfo: UserInfo?
    var picker: UIImagePickerController?
    var indexOfCurrentHttpRequest: httpRequest?
    
    @IBOutlet weak var imageView_avatar: UIImageView!
    @IBOutlet weak var label_username: UILabel!
    @IBOutlet weak var label_email: UILabel!
    @IBOutlet weak var label_phone: UILabel!
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_citizenId: UILabel!
    
    enum httpRequest {
        case UploadAvatar
        case LogoutUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: self, action: "presentLeftMenuViewController:")
        
        Toolbox.loadAvatarImage(Singleton_CurrentUser.sharedInstance.userId, toImageView: self.imageView_avatar!)
        
        Appearance.customizeAvatarImage(self.imageView_avatar)
        
        // listen to userInfoUpdated message and show HUD to indicate that user info updated successfully
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showUpdatedUserInfo", name: "userInfoUpdated", object: nil)
        self.displayUserInfo()
        
        // add tap gesture event to imageView_avatar, when imageView_avatar is tapped, user will be provided with options to whether select image or shoot a photo as avatar to upload
        let singleTap = UITapGestureRecognizer(target: self, action: "avatarImageTapped")
        singleTap.numberOfTapsRequired = 1
        
        self.imageView_avatar.userInteractionEnabled = true
        self.imageView_avatar.addGestureRecognizer(singleTap)
    }
    
    func avatarImageTapped() {
        let selectPhoto = "Choose photo"
        let takePhoto = "Shoot photo"
        let cancelTitle = "Cancel"
        let actionSheet: UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil, otherButtonTitles: selectPhoto, takePhoto)
        actionSheet.showInView(self.view)
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
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if self.picker != nil {
            self.picker?.delegate = nil
        }
        self.picker = nil
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.imageView_avatar.image = image
        self.uploadAvatar(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if self.picker != nil {
            self.picker?.delegate = nil
        }
        self.picker = nil
    }
    
    func uploadAvatar(image: UIImage) {
        var connection = Toolbox.uploadImageToURL(URLUploadUserAvatar, image: image, parameters: ["modelId": Singleton_CurrentUser.sharedInstance.userId], delegate: self)
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
    
    func displayUserInfo() {
        self.label_username.text = Singleton_CurrentUser.sharedInstance.username
        self.label_email.text = Singleton_CurrentUser.sharedInstance.email
        self.label_phone.text = Singleton_CurrentUser.sharedInstance.phoneNumber
        self.label_name.text = Singleton_CurrentUser.sharedInstance.name
        self.label_citizenId.text = Singleton_CurrentUser.sharedInstance.citizenID
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Appearance.customizeNavigationBar(self, title: "User info")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showUpdatedUserInfo() {
        Toolbox.showCustomAlertViewWithImage("checkmark", title: "User info updated")
        self.displayUserInfo()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            if indexPath.row == 0 {             // change username
                self.selectedUserInfo = .Username
            } else if indexPath.row == 1 {      // change email
                self.selectedUserInfo = .Email
            } else if indexPath.row == 2 {      // chane phone
                self.selectedUserInfo = .Phone
            }
            self.performSegueWithIdentifier("changeUserInfoSegue", sender: self)
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {             // change name
                self.selectedUserInfo = .Name
            } else if indexPath.row == 1 {      // change citizen id
                self.selectedUserInfo = .CitizenId
            }
            self.performSegueWithIdentifier("changeUserInfoSegue", sender: self)
        } else if indexPath.section == 4 {
            self.submitLogout()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "changeUserInfoSegue" {
            let destinationViewController = segue.destinationViewController as! ChangeUserInfoViewController
            destinationViewController.currentUserInfo = self.selectedUserInfo
        }
    }
    
    func submitLogout() {
        var connection = Toolbox.asyncHttpGetFromURL("\(URLLogout)?id=\(Singleton_CurrentUser.sharedInstance.userId)", delegate: self)
        if connection == nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "Network connection failed")
        } else {
            self.indexOfCurrentHttpRequest = .LogoutUser
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
        
        if self.indexOfCurrentHttpRequest == .LogoutUser {
            let responseStr = NSString(data: self.responseData!, encoding: NSUTF8StringEncoding)
            if responseStr == "logged out" {    // successfully logged out
                Singleton_CurrentUser.sharedInstance.logout()
            } else {
                Toolbox.showCustomAlertViewWithImage("unhappy", title: "Logout failed")
            }
        } else if self.indexOfCurrentHttpRequest == .UploadAvatar {
            // save successfully uploaded user avatar to local app directory
            let saveAvatarLocally = Toolbox.saveAvatarImageLocally(self.imageView_avatar.image!, modelId: Singleton_CurrentUser.sharedInstance.userId)
            if !saveAvatarLocally {
                Toolbox.showCustomAlertViewWithImage("unhappy", title: "Save avatar locally failed")
            } else {
                // notify that user info has been updated
                NSNotificationCenter.defaultCenter().postNotificationName("userInfoUpdated", object: nil)
            }
        }
        
        self.responseData = nil
        self.responseData = NSMutableData()
    }
    
    deinit {
        self.HUD = nil
        self.responseData = nil
        self.selectedUserInfo = nil
        self.picker = nil
        self.indexOfCurrentHttpRequest = nil
    }

}
