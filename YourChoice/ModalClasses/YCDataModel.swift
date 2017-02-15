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
    
    class func resetPasswordWithEmail(_ email: String) {
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
    class func createUserWithEmail(_ username: String, email: String, password: String, profilePicture: UIImage?) {
        fireAuth.createUser(withEmail: email, password: password) { user, error in
            var userInfo: [String: String]? = nil
            if error != nil {
                userInfo = [String: String]()
                userInfo![NotificationData.Message] = getAuthenticationError(error! as NSError)
            } else {
                setUserDetails(user!.uid, username: username, profilePicture: profilePicture)
            }
            
            defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.CreateUserCompleted), object: nil, userInfo: userInfo)
        }
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
    fileprivate class func fetchPhotoById(_ id: String) -> Photo? {
        let predicate = NSPredicate(format: "id == %@", id)
        let photos = fetchPhotos(predicate)
        
        return (photos?.count)! > 0 ? photos![0] : nil
    }
    fileprivate class func fetchPhotos(_ predicate: NSPredicate) -> [Photo]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Photo.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.predicate = predicate
        
        var photos: [Photo]? = nil
        do {
            photos = try context.fetch(request) as? [Photo]
        } catch let error as NSError {
            print("Error in fetchPhoto \(error)")
        }
        
        return photos
    }
}
//MARK: - Firebase storage
extension YCDataModel{

    class func getProfilePicture(_ id: String?, rowIndex: Int?) -> UIImage {
        guard let id = id else {
            return UIImage(named: "ProfilePicture")!
        }
        
        let photo = fetchPhotoById(id)
        guard photo != nil, let image = photo!.image else {
            downloadProfilePicture(id, isThumbnail: true, rowIndex: rowIndex)
            return UIImage(named: "ProfilePicture")!
        }
        
        return image
    }
    
    fileprivate class func downloadProfilePicture(_ id: String, isThumbnail: Bool, rowIndex: Int?) {
        let profilePictureRef = fireStorage.child(FirebaseConstants.BucketProfilePictures).child(id)
        profilePictureRef.data(withMaxSize: 1 * 8192 * 8192) { data, error in
            if error == nil {
                let image = UIImage(data: data!)
                let photo = Photo(id: id, pollId: nil, uploaded: true, isThumbnail: true, image: image, context: context)
                saveContext()
                let userInfo = [NotificationData.Photo: photo,
                                NotificationData.RowIndex: rowIndex!] as [String : Any]
                defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.PhotoDownloadCompleted), object: nil, userInfo: userInfo)
            }
        }
    }
    
    fileprivate class func uploadProfilePicture(_ userId: String, photo: Photo?) {
        guard let profilePicturePhoto = photo else {
            return
        }
        
        let file = URL(fileURLWithPath: profilePicturePhoto.path!)
        let profilePictureRef = fireStorage.child(FirebaseConstants.BucketProfilePictures).child(profilePicturePhoto.id)
        profilePictureRef.putFile(file, metadata: nil) { metadata, error in
            if error == nil {
                profilePicturePhoto.uploaded = true
                saveContext()
                let userDetails = [FirebaseConstants.ProfilePictureId: profilePicturePhoto.id]
                updateUserDetails(userId, userDetails: userDetails as [String : AnyObject])
            }
        }
    }
    fileprivate class func updateUserDetails(_ uid: String, userDetails: [String: AnyObject]) {
        let users = fireDatabase.child(FirebaseConstants.Users).child(uid)
        users.updateChildValues(userDetails)
    }
}
// MARK: - Firebase database
extension YCDataModel{
    class func setUserDetails(_ userId: String, username: String, profilePicture: UIImage?) {
        // Set the user details.
        let users = fireDatabase.child(FirebaseConstants.Users).child(userId)
        let userDetails = [FirebaseConstants.Username: username]
        
        users.setValue(userDetails) { error, firebase in
            if error == nil {
                let photo = createProfilePicturePhoto(userId, image: profilePicture)
                uploadProfilePicture(userId, photo: photo)
            }
        }
    }
}
//MARK:- Convience Methods
extension YCDataModel{
    fileprivate class func createProfilePicturePhoto(_ id: String, image: UIImage?) -> Photo? {
        guard let profilePictureImage = image else {
            return nil
        }
        
        let targetSize = CGSize(width: ImageConstants.ProfilePictureThumbnailWidth, height: ImageConstants.ProfilePictureThumbnailHeight)
        let thumbnail = YCUtils.resizeImage(profilePictureImage, targetSize: targetSize)
        let profilePictureId = id + ImageConstants.ProfilePictureJPEG
        let photo = Photo(id: profilePictureId, pollId: nil, uploaded: false, isThumbnail: true, image: thumbnail, context: context)
        saveContext()
        return photo
    }
}
