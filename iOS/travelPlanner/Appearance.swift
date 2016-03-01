//
//  Appearance.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/28.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

import UIKit

let ColorBackgroundGray = UIColor(red: 244/255.0, green: 245/255.0, blue: 249/255.0, alpha: 1.0)
let ColorSettledGreen = UIColor(red: 101/255.0, green: 192/255.0, blue: 89/255.0, alpha: 1.0)

@objc class Appearance: NSObject {
    
    static func setupRefreshControl() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.blackColor()
        refreshControl.backgroundColor = ColorBackgroundGray
        
        return refreshControl
    }
    
    static func setupTableFooterButtonWithTitle(title: String, backgroundColor: UIColor) -> UIButton {
        let tableFooterButton = UIButton(type: .System)
        tableFooterButton.setTitle(title, forState: .Normal)
        tableFooterButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        tableFooterButton.backgroundColor = backgroundColor
        
        tableFooterButton.frame = CGRect(x: 15, y: 15, width: ScreenSize.width - 30, height: 40)
        tableFooterButton.layer.cornerRadius = 2.0
        
        return tableFooterButton
    }
    
    static func customizeTextField(textField: UITextField, iconName: String) {
        let borderColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1.0)
        
        // make the textField has only bottom border
        let borderWidth: CGFloat = 1
        let textFieldBorder = UIView(frame: CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, borderWidth))
        textFieldBorder.backgroundColor = borderColor
        textField.addSubview(textFieldBorder)
        // add icon padding inside textField
        let icon = UIImageView(image: UIImage(named: iconName))
        icon.frame = CGRect(x: 0, y: 0, width: icon.image!.size.width + 15.0, height: icon.image!.size.height)
        icon.contentMode = .Center
        
        // add left side icon inside textField
        textField.leftViewMode = .Always
        textField.leftView = icon
        textField.clearButtonMode = .WhileEditing
    }
    
    static func customizeAvatarImage(avatarImage: UIImageView) {
        avatarImage.backgroundColor = UIColor.whiteColor()
        avatarImage.layer.borderWidth = 2.0
        avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2
    }
    
    static func customizeNavigationBar(viewController: UIViewController, title: String) {
        viewController.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        viewController.navigationController?.navigationBar.topItem!.title = ""
        viewController.title = title
    }
    
    static func customizeTextView(textView: UITextView, placeholder p: String?) {
        let borderColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1.0)
        let textViewBorder = CALayer()
        
        textViewBorder.borderColor = borderColor.CGColor
        textViewBorder.frame = CGRect(x: 0, y: textView.frame.size.height - 1, width: textView.frame.size.width, height: textView.frame.size.height)
        textViewBorder.borderWidth = 1
        
        textView.layer.addSublayer(textViewBorder)
        textView.layer.masksToBounds = true
        
        textView.placeholder = p
    }
    
    static func addRightViewToTextField(textField: UITextField, withText text: String) {
        let rightView = UILabel(frame: CGRectMake(0, 0, 40, 21))
        rightView.contentMode = .Center
        rightView.text = text
        textField.rightViewMode = .Always
        textField.rightView = rightView
    }
    
}