//
//  YCBaseViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 14/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
//MARK:- YC Base View Controller class
class YCBaseViewController: UIViewController {
    //MARK:- Intialization
    let activityIndicatorUtils = YCActivityIndicator.sharedInstance()
    let defaultCenter = NotificationCenter.default
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Lifecycle methods.
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Convenience methods.
    
    func createAlertController(_ title: String, message: String) {
        alertController = YCUtils.createAlertController(title, message: message)
        present(alertController!, animated: true, completion: nil)
    }

}

