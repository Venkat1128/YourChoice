//
//  YCImageUpdateViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 17/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
protocol YCImageUpdateViewControllerDeleage {
    func imageChanged(_ image: UIImage?)

}

class YCImageUpdateViewController: YCImagePickerViewController {

    var image: UIImage!
    var delegate: YCImageUpdateViewControllerDeleage?
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func changePhoto(_ sender: AnyObject) {
        createImagePickerAlertController()
    }
    
    @IBAction func deletePhoto(_ sender: AnyObject) {
        delegate?.imageChanged(nil)
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    // MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate methods.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            delegate?.imageChanged(pickedImage)
            image = pickedImage
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }

}
