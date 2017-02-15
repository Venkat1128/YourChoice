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
    
    fileprivate class var fireDatabase: FIRDatabaseReference{
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
        getUserDetails(currentUser?.uid)
    }
    
}
//MARK:- User Authentication Methods
extension YCDataModel{
    
    class func getUserDetails(_ userId: String?) {
        guard let userId = userId else {
            return
        }
        
        // If user details have already been saved then authorise the user.
        guard fetchUser() == nil else {
            defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.AuthUserCompleted), object: nil, userInfo: nil)
            return
        }
        
        // Download the new user's details.
        let users = fireDatabase.child(FirebaseConstants.Users).child(userId)
        users.observeSingleEvent(of: .value, with: { snapshot in
            let _ = User(snapshot: snapshot, context: context)
            saveContext()
            defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.AuthUserCompleted), object: nil, userInfo: nil)
        })
    }
    class func signInWithEmail(_ email: String, password: String) {
        fireAuth.signIn(withEmail: email, password: password) { user, error in
            var userInfo: [String: String]? = nil
            if let error = error {
                userInfo = [String: String]()
                userInfo![NotificationData.Message] = getAuthenticationError(error as NSError)
                defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.AuthUserCompleted), object: nil, userInfo: userInfo)
                return
            } else {
                getUserDetails(user!.uid)
            }
        }
    }
    class func signOut() {
        try! fireAuth.signOut()
        
        // Remove the existing user.
        if let user = fetchUser() {
            context.delete(user)
            saveContext()
        }
    }
    
    class func sendPasswordResetWithEmail(_ email: String) {
        fireAuth.sendPasswordReset(withEmail: email) { error in
            var userInfo: [String: String] = [String: String]()
            if error != nil {
                userInfo[NotificationData.Title] = Title.Error
                userInfo[NotificationData.Message] = Error.ErrorResettingPassword
            } else {
                userInfo[NotificationData.Title] = Title.PasswordReset
                userInfo[NotificationData.Message] = Message.CheckEmailForPassword
            }
            
            defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.ResetPasswordForUserCompleted), object: nil, userInfo: userInfo)
        }
    }
    class func getAuthenticationError(_ error: NSError) -> String {
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .errorCodeUserNotFound:
                return Error.UserDoesNotExist
            case .errorCodeInvalidEmail:
                return Error.EmailInvalidTryAgain
            case .errorCodeWrongPassword:
                return Error.PasswordIncorrectTryAgain
            case .errorCodeEmailAlreadyInUse:
                return Error.EmailTaken
            default:
                return Error.UnexpectedError
            }
        }
        
        return Error.UnexpectedError
    }

}
//MARK:- Core Data
extension YCDataModel{
    
    fileprivate class func fetchUser() -> User? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: User.EntityName)
        
        var users: [User]? = nil
        do {
            users = try context.fetch(request) as? [User]
        } catch let error as NSError {
            print("Error in fetchUser \(error)")
        }
        
        return (users?.count)! > 0 ? users![0] : nil
    }
    
}
