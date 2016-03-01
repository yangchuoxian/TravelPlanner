//
//  Toolbox.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/28.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

class Toolbox: NSObject, MBProgressHUDDelegate {
    
    static func toggleButton(button: UIButton, enabled e: Bool) {
        button.enabled = e
        if e {
            button.alpha = 1.0
        } else {
            button.alpha = 0.5
        }
    }
    
    /**
     * Given a date string, check to see if it is the format of "yyyy-MM-dd'T'HH:mm:ss.SSSz"
     */
    static func isDateStringServerDateFormat(dateString: String) -> Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        let dateTimeString = dateFormatter.dateFromString(dateString)
        if dateTimeString != nil {
            return true
        }
        return false
    }
    
    /**
     * Get rid of blank and new line characters at the front and end of strings,
     * also remove special character '&'
     */
    static func trim(string: String) -> String {
        // trim string
        let trimmedString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return trimmedString.stringByReplacingOccurrencesOfString("&", withString: "", options: .LiteralSearch, range: nil)
    }
    
    static func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    /* ASYNCHRONOUS http post request */
    static func asyncHttpPostToURL(url: String, parameters postParametersString: String, delegate d: AnyObject?) -> NSURLConnection? {
        let completePostParamsString = Toolbox.addLoginTokenAndCurrentUserIdToHttpRequestParameters(postParametersString)
        let postParametersStringThatEscapedSpecialCharacters = completePostParamsString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        // set post parameters
        let postParametersData = postParametersStringThatEscapedSpecialCharacters!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let postParametersLength = "\((postParametersStringThatEscapedSpecialCharacters!).characters.count)"
        // http request to get service agreement content from server
        let url_encoded = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let request = NSMutableURLRequest(URL: NSURL(string: url_encoded!)!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: TimeIntervals.HttpRequestTimeout.rawValue)
        request.HTTPMethod = "POST"
        request.setValue(postParametersLength, forHTTPHeaderField: "Content-Length")
        request.HTTPBody = postParametersData
        
        // start asynchronous http request
        return NSURLConnection(request: request, delegate: d)
    }
    
    /* ASYNCHRONOUS http get request */
    static func asyncHttpGetFromURL(url: String, delegate d: AnyObject) -> NSURLConnection? {
        let completeUrl = Toolbox.addLoginTokenAndCurrentUserIdToHttpRequestParameters(url)
        let url_encoded = completeUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let request = NSMutableURLRequest(URL: NSURL(string: url_encoded!)!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: TimeIntervals.HttpRequestTimeout.rawValue)
        request.HTTPMethod = "GET"
        return NSURLConnection(request: request, delegate: d)
    }
    
    /* SYNCHRONOUS http get request */
    static func syncHttpGetFromURL(url: String) -> NSData? {
        let completeUrl = Toolbox.addLoginTokenAndCurrentUserIdToHttpRequestParameters(url)
        let url_encoded = completeUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let request = NSMutableURLRequest(URL: NSURL(string: url_encoded!)!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: TimeIntervals.HttpRequestTimeout.rawValue)
        request.HTTPMethod = "GET"
        var response: NSURLResponse?
        var error: NSError?
        let responseData: NSData?
        do {
            responseData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        } catch let error1 as NSError {
            error = error1
            responseData = nil
        }
        if error != nil {
            Toolbox.showCustomAlertViewWithImage("unhappy", title: "无法连接服务器")
            return nil
        }
        return responseData
    }
    
    static func uploadImageToURL(url: String, image i: UIImage, parameters pDictionary: [NSObject: AnyObject]?, delegate d: AnyObject) -> NSURLConnection? {
        let httpDataBoundary = "---------------------------14737809831466499882746641449"
        
        let imageData = UIImageJPEGRepresentation(i, 1.0)
        let imageExtension = ".jpg"
        let contentType = "multipart/form-data; boundary=\(httpDataBoundary)"
        
        let body = NSMutableData()
        if pDictionary != nil {
            for (name, value) in pDictionary! {
                body.appendData("--\(httpDataBoundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("\(value)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        
        // get login token and currentUserId from userDefaults
        let credentialInfo = Toolbox.getUserCredential()
        if credentialInfo != nil {
            for (name, value) in credentialInfo! {
                body.appendData("--\(httpDataBoundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("\(value)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        
        body.appendData("\r\n--\(httpDataBoundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"avatar\"; filename=\"user_avatar\(imageExtension)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        body.appendData(NSData(data: imageData!))
        body.appendData("\r\n--\(httpDataBoundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let url_encoded = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let request = NSMutableURLRequest(URL: NSURL(string: url_encoded!)!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: TimeIntervals.ImageUploadTimeout.rawValue)
        request.HTTPMethod = "POST"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        // set the content-length
        let postLength = "\(body.length)"
        
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.HTTPBody = body
        // start asynchronous http request
        return NSURLConnection(request: request, delegate: d)
    }
    
    static func saveAvatarImageLocally(avatarImage: UIImage, modelId mId: String) -> Bool {
        let imageData = UIImagePNGRepresentation(avatarImage)
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let imagePath = "\(documentsDirectory)/\(mId).png"
        
        return imageData!.writeToFile(imagePath, atomically: false)
    }
    
    /**
     Load avatar image to designated image view
     1. If the avatar image exists locally, load it from local file
     2. If the avatar image DOES NOT exist, load it ASYNCHRONOUSLY from URL and the save it locally
     
     - parameter modelId:   the team or user id
     - parameter imageView: the imageView to show the avatar
     - parameter aType:     whether the avatar is for team or user
     */
    static func loadAvatarImage(modelId: String, toImageView imageView: UIImageView) {
        // load avatar image
        let avatarPath = Toolbox.getAvatarImagePathForModelId(modelId)
        if avatarPath != nil {    // current user avatar image file exists locally
            imageView.image = UIImage(contentsOfFile: avatarPath!)
        } else {                        // current user avatar image file not exists, load it from url
            // set the current user avatar to local default avatar,
            // in the mean time, start to download the avatar asynchronously,
            // if the avatar image doesn't exist even on server side, then use the local default avatar instead
            imageView.image = UIImage(named: "avatar")
            Toolbox.asyncDownloadAvatarImageForModelId(modelId, completionBlock: {
                succeeded, image in
                if (succeeded) {
                    imageView.image = image
                }
                return
            })
        }
    }
    
    /**
     * Asynchronously download avatar image from url and save it as a file locally.
     * The name of avatar file is always <user id>.png
     */
    static func asyncDownloadAvatarImageForModelId(modelId: String, completionBlock: ((Bool, UIImage?) -> Void)?) {
        let urlWithParams = Toolbox.addLoginTokenAndCurrentUserIdToHttpRequestParameters(URLUserAvatar + modelId)
        let request = NSMutableURLRequest(URL: NSURL(string: urlWithParams)!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            let httpResponse = response as? NSHTTPURLResponse
            if httpResponse != nil {
                if httpResponse?.statusCode == HttpStatusCode.OK.rawValue {  // avatar download succeeded
                    let image = UIImage(data: data!)
                    // save successfully downloaded user avatar to local app directory with name <user id>.png
                    if image != nil {
                        self.saveAvatarImageLocally(image!, modelId: modelId)
                        completionBlock!(true, image)
                    } else {
                        completionBlock!(false, nil)
                    }
                } else { // avatar download failed, probably because the user has not setup his/her avatar
                    completionBlock!(false, nil)
                }
            } else {
                completionBlock!(false, nil)
            }
        })
    }
    
    /**
     * For http requests sent from mobile native app, the server validates whether
     * the request is sent by logged in user by checking the login token and user id,
     * if it matches, the request can go through, otherwise, it is an illegal request
     */
    static func addLoginTokenAndCurrentUserIdToHttpRequestParameters(urlOrPostParameters: String) -> String {
        let userCredential = Toolbox.getUserCredential()
        if userCredential != nil {
            let loginToken = userCredential!["loginToken"]
            let currentUserId = userCredential!["currentUserId"]
            return urlOrPostParameters + "&loginToken=\(loginToken!)&currentUserId=\(currentUserId!)"
        } else {
            return urlOrPostParameters
        }
    }
    
    /*
    * Get avatar image path for user based on its model id,
    * also check if that avata image file exists,
    * if not, return nil, if it does, return the file path
    * NOTE: model id is the mongodb id of that corresponding record saved in server,
    * it could represents either a user or a team, since both user and team are allowed
    * to have an avatar
    */
    static func getAvatarImagePathForModelId(modelId: String) -> String? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let avatarFilePath = "\(documentsPath)/\(modelId).png"
        let avatarFileExists = NSFileManager.defaultManager().fileExistsAtPath(avatarFilePath)
        if avatarFileExists {
            return avatarFilePath
        } else {
            return nil
        }
    }
    
    static func showCustomAlertViewWithImage(imageName: String, title t: String) {
        var HUD = MBProgressHUD(view: Toolbox.getCurrentViewController()?.view)
        Toolbox.getCurrentViewController()?.view.addSubview(HUD)
        HUD.customView = UIImageView(image: UIImage(named: imageName))
        // Set custom view mode
        HUD.mode = .CustomView
        HUD.labelText = t
        HUD.show(true)
        // hide and remove HUD view a while after
        HUD.hide(true, afterDelay: 1)
        HUD = nil
    }
    
    static func getUserCredential() -> [String: String]? {
        let keychainItem = KeychainItemWrapper(identifier: "TravelPlannerLogin", accessGroup: nil)
        let currentUserId = keychainItem.objectForKey(kSecAttrAccount) as? String
        let loginTokenData = keychainItem.objectForKey(kSecValueData) as? NSData
        var loginToken: NSString?
        if Toolbox.isStringValueValid(currentUserId) && loginTokenData != nil {
            loginToken = NSString(data: loginTokenData!, encoding: NSUTF8StringEncoding)
            return [
                "currentUserId": currentUserId!,
                "loginToken": loginToken as! String
            ]
        } else {
            return nil
        }
    }
    
    static func setupCustomProcessingViewWithTitle(title t: String?) -> MBProgressHUD {
        let HUD = MBProgressHUD(view: Toolbox.getCurrentViewController()?.view)
        if Toolbox.isStringValueValid(t) {
            HUD.labelText = t
        }
        Toolbox.getCurrentViewController()?.view.addSubview(HUD)
        HUD.show(true)
        return HUD
    }
    
    static func isStringValueValid(value: String?) -> Bool {
        if value == nil {
            return false
        }
        if (value!).characters.count == 0 {
            return false
        }
        if value == "<null>" {
            return false
        }
        return true
    }
    
    /**
     * Get the topmost current showing view controller
     */
    static func getCurrentViewController() -> UIViewController? {
        // get current view controller
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller
            return topController
        }
        return UIApplication.sharedApplication().delegate?.window??.rootViewController
    }
    
    /**
     * Function to store username and password in keychain
     */
    static func saveUserCredential(currentUserId: String, loginToken token: String) {
        // store username and password in keychain
        var keychainItem = KeychainItemWrapper(identifier: "TravelPlannerLogin", accessGroup: nil)
        keychainItem.setObject(currentUserId, forKey: kSecAttrAccount)
        keychainItem.setObject(token, forKey: kSecValueData)
        keychainItem = nil
    }
    
}