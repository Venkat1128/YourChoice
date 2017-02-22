//
//  YCImagePickerViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 15/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit

class YCImagePickerViewController: YCBaseViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    // MARK: - Handler methods for alert controller.
    
    func cameraHandler(_ alertAction: UIAlertAction) {
        let imagePickerController = YCUtils.getImagePickerController(.camera, delegate: self)
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func photoLibraryHandler(_ alertAction: UIAlertAction) {
        let imagePickerController = YCUtils.getImagePickerController(.photoLibrary, delegate: self)
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Convenience methods.
    
    func createImagePickerAlertController() {
        let isCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        if isCamera {
            alertController = YCUtils.createImagePickerAlertController(Title.AddProfilePicture, cameraHandler: cameraHandler, photoLibraryHandler: photoLibraryHandler)
            present(alertController!, animated: true, completion: nil)
        } else {
            let imagePickerController = YCUtils.getImagePickerController(.photoLibrary, delegate: self)
            present(imagePickerController, animated: true, completion: nil)
        }
    }

}
