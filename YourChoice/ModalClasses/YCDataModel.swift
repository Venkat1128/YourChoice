//
//  YCDataModel.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 15/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
import Firebase
import CoreData
//MARK:- YC Data Model
class YCDataModel: NSObject {
    
    static let MaxDownloadRetryTime: TimeInterval = 30
    
    fileprivate class var fireAuth: FIRAuth {
        return FIRAuth.auth()!
    }
    
    fileprivate class var fireDatebase: FIRDatabaseReference{
        return FIRDatabase.database().reference()
    }
    
    
    fileprivate class var fireStorage: FIRStorageReference{
        return FIRStorage.storage().reference()
    }
    
    fileprivate class var defaultCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    fileprivate class var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    fileprivate class func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    //MARK:- FIR Authentication
    
    class func getUserId() -> String {
        return fireAuth.currentUser!.uid
    }
    
    class func authUser(_ authUserCallback: (_ isCurrentUser: Bool) -> Void) {
        let currentUser = fireAuth.currentUser
        authUserCallback(currentUser != nil)
        //getUserDetails(currentUser?.uid)
    }
}
