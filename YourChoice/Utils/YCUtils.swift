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

    // Create an image picker alert controller to display to the screen
    static func createImagePickerAlertController(_ title: String, cameraHandler: @escaping ((UIAlertAction) -> Void), photoLibraryHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: Button.Camera, style: .default, handler: cameraHandler)
        alertController.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: Button.PhotoLibrary, style: .default, handler: photoLibraryHandler)
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: Button.Cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    // Get an image picker controller with the provided source type.
    static func getImagePickerController(_ sourceType : UIImagePickerControllerSourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> UIImagePickerController {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = delegate
        return imagePickerController
    }
    
    static func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else if widthRatio < heightRatio {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        } else {
            newSize = CGSize(width: targetSize.width, height: targetSize.height)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

}
