//
//  YCActivityIndicator.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 14/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import Foundation
import UIKit

class YCActivityIndicator {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class func sharedInstance() -> YCActivityIndicator{
        
        struct Singleton{
            static var sharedInstance = YCActivityIndicator()
        }
        return Singleton.sharedInstance
    }
    
    // Show customized activity indicator within the view provided
    func showProgressView(_ view: UIView) {
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = YCUtils.uiColorFromHex(0xffffff, alpha: 0.7)
        
        progressView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        progressView.center = view.center
        progressView.backgroundColor = YCUtils.uiColorFromHex(0x444444, alpha: 0.7)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    // Hide activity indicator
    func hideProgressView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }

}
