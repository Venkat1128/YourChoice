//
//  YCUtils.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 14/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import Foundation
import UIKit
//MARK:- App Common Util class.
class YCUtils{
    
    //MARK:-  Define UIColor from hex value
    static func uiColorFromHex(_ rgbValue: UInt32, alpha: Double = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 256.0
        let blue = CGFloat(rgbValue & 0xFF) / 256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // Create an alert controller to display to the screen 
    static func createAlertController(_ title: String?, message: String?) -> UIAlertController {
        
        let okButtonName = Button.Ok
        return createAlertController(title, message: message, okButtonName: okButtonName, noButtonName: nil, positiveButtonAction: nil, negativeButtonAction: nil, textFieldHandler: nil)
    }
    
    // Create an alert controller to display to the screen
    static func createAlertController(_ title: String?, message: String?, okButtonName: String?, positiveButtonAction: ((UIAlertAction) -> Void)?) -> UIAlertController {
        
        return createAlertController(title, message: message, okButtonName: okButtonName, noButtonName: nil, positiveButtonAction: positiveButtonAction, negativeButtonAction: nil, textFieldHandler: nil)
    }
    
    // Create an alert controller to display to the screen
    static func createAlertController(_ title: String?, message: String?, okButtonName: String?, noButtonName: String?, positiveButtonAction: ((UIAlertAction) -> Void)?, negativeButtonAction: ((UIAlertAction) -> Void)?, textFieldHandler: ((UITextField) -> Void)?) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if okButtonName != nil {
            let positiveAction = UIAlertAction(title: okButtonName, style: .default, handler: positiveButtonAction)
            alertController.addAction(positiveAction)
        }
        
        if noButtonName != nil {
            let negativeAction = UIAlertAction(title: noButtonName, style: .cancel, handler: negativeButtonAction)
            alertController.addAction(negativeAction)
        }
        
        if textFieldHandler != nil {
            alertController.addTextField(configurationHandler: textFieldHandler)
        }
        
        return alertController
    }

}
