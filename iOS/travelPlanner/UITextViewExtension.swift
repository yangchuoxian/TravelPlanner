//
//  UITextViewExtension.swift
//  travelPlanner
//
//  Created by 杨逴先 on 16/2/28.
//  Copyright © 2016年 VisionTech. All rights reserved.
//

extension UITextView {
    // Placeholder text
    var placeholder: String? {
        get {
            // Get the placeholder text from the label
            var placeholderText: String?
            if let placeHolderLabel = self.viewWithTag(TagValue.TextViewPlaceholder.rawValue) as? UILabel {
                placeholderText = placeHolderLabel.text
            }
            return placeholderText
        }
        set {
            // Store the placeholder text in the label
            let placeHolderLabel = self.viewWithTag(TagValue.TextViewPlaceholder.rawValue) as? UILabel
            if placeHolderLabel == nil {
                // Add placeholder label to text view
                self.addPlaceholderLabel(newValue!)
            } else {
                placeHolderLabel?.text = newValue
                placeHolderLabel?.sizeToFit()
            }
            
            // if there are text in text view, DON'T show placeholder label
            if self.text.characters.count > 0 {
                placeHolderLabel?.hidden = true
            }
        }
    }
    
    // Add a placeholder label to the text view
    func addPlaceholderLabel(placeholderText: String) {
        // Create the label and set its properties
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin.x = 5.0
        placeholderLabel.frame.origin.y = 5.0
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGrayColor()
        placeholderLabel.tag = TagValue.TextViewPlaceholder.rawValue
        
        // Hide the label if there is text in the text view
        placeholderLabel.hidden = (self.text.characters.count > 0)
        self.addSubview(placeholderLabel)
    }
}