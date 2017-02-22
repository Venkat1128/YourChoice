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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
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
        FIRStorage.storage().maxDownloadRetryTime = MaxDownloadRetryTime
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
    fileprivate class func fetchLocalOnlyPhotos() -> [Photo]? {
        var predicate: NSPredicate
        if let profilePictureId = getProfilePictureId() {
            predicate = NSPredicate(format: "(id != %@) AND (uploaded == %@)", profilePictureId, false as CVarArg)
        } else {
            predicate = NSPredicate(format: "uploaded == %@", false as CVarArg)
        }
        
        let photos = fetchPhotos(predicate)
        
        return photos
    }
    fileprivate class func fetchPhotosByPollId(_ pollId: String, isThumbnail: Bool) -> [Photo]? {
        let predicate = NSPredicate(format: "(pollId == %@) AND (isThumbnail == %@)", pollId, isThumbnail as CVarArg)
        let photos = fetchPhotos(predicate)
        
        return photos
    }
    class func voteOnPoll(_ poll: Choice, pollOptionIndex: Int) {
        let voteCount = fireDatabase.child(FirebaseConstants.Polls).child(poll.id!).child(FirebaseConstants.PollOptions).child(String(pollOptionIndex)).child(FirebaseConstants.VoteCount)
        voteCount.runTransactionBlock() { currentData in
            let count = currentData.value as? Int ?? 0
            currentData.value = count + 1
            return FIRTransactionResult.success(withValue: currentData)
        }
        
        let votedPolls = fireDatabase.child(FirebaseConstants.Users).child(getUserId()).child(FirebaseConstants.VotedPolls).child(poll.id!)
        votedPolls.setValue(pollOptionIndex)
    }
    
    class func getPollOptionIndex(_ poll: Choice) {
        let pollOptionIndex = fireDatabase.child(FirebaseConstants.Users).child(getUserId()).child(FirebaseConstants.VotedPolls).child(poll.id!)
        pollOptionIndex.observeSingleEvent(of: .value, with: { snapshot in
            var userInfo: [String: AnyObject]? = nil
            if let index = snapshot.value as? NSNumber {
                userInfo = [NotificationData.PollOptionIndex: Int(index) as AnyObject]
            }
            defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.GetPollOptionIndexCompleted), object: nil, userInfo: userInfo)
        })
    }
}
//MARK: - Firebase storage
extension YCDataModel{

    class func getProfilePicture(_ id: String?, rowIndex: Int?) -> UIImage {
        guard let id = id else {
            return UIImage(named: "Profile")!
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
    class func getPollPictures(_ poll: Choice, isThumbnail: Bool, rowIndex: Int?) -> [UIImage?] {
        var images = [UIImage?]()
        let photos = fetchPhotosByPollId(poll.id!, isThumbnail: isThumbnail)
        
        for pollOption in poll.pollOptions {
            var hasPhoto = false
            if (photos?.count)! > 0 {
                for photo in photos! {
                    // Add images to the array if they are stored locally.
                    let photoId = isThumbnail ? pollOption.pollPictureThumbnailId : pollOption.pollPictureId
                    if photoId == photo.id, let image = photo.image {
                        images.append(image)
                        hasPhoto = true
                        break
                    }
                }
            }
            
            if !hasPhoto {
                // If the photo is not saved locally then download it.
                images.append(nil)
                let id = isThumbnail ? pollOption.pollPictureThumbnailId : pollOption.pollPictureId
                downloadPollPicture(id, pollId: poll.id!, isThumbnail: isThumbnail, rowIndex: rowIndex)
            }
        }
        
        return images
    }
    fileprivate class func downloadPollPicture(_ id: String, pollId: String, isThumbnail: Bool, rowIndex: Int?) {
        let pollPicturesRef = fireStorage.child(FirebaseConstants.BucketPollPictures).child(id)
        pollPicturesRef.data(withMaxSize: 1 * 8192 * 8192) { data, error in
            var userInfo: [String: AnyObject]?
            if error == nil {
                let image = UIImage(data: data!)
                let photo = Photo(id: id, pollId: pollId, uploaded: true, isThumbnail: isThumbnail, image: image, context: context)
                saveContext()
                
                userInfo = [NotificationData.Photo: photo, NotificationData.RowIndex: rowIndex! as AnyObject] as [String:AnyObject]
            }
            
            defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.PhotoDownloadCompleted), object: nil, userInfo: userInfo)
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
    fileprivate class func uploadLocalOnlyPhotos() {
        // Upload the profile picture if it is only stored locally.
        if let profilePicture = getProfilePicture(), !profilePicture.uploaded {
            uploadProfilePicture(getUserId(), photo: profilePicture)
        }
        
        // Uploaded poll pictures if they are only stored locally.
        if let photos = fetchLocalOnlyPhotos(), photos.count > 0 {
            uploadPollPictures(photos)
        }
    }
    fileprivate class func uploadPollPictures(_ photos: [Photo]) {
        let pollPicturesRef = fireStorage.child(FirebaseConstants.BucketPollPictures)
        
        for photo in photos {
            let file = URL(fileURLWithPath: photo.path!)
            let pollPictureRef = pollPicturesRef.child(photo.id)
            pollPictureRef.putFile(file, metadata: nil) { metadata, error in
                if error == nil {
                    photo.uploaded = true
                    saveContext()
                }
            }
        }
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
    class func addPoll(_ question: String, images: [UIImage]) {
        let pollRef = fireDatabase.child(FirebaseConstants.Polls).childByAutoId()
        let pollId = pollRef.key
        
        // Store the images with core data.
        var pollOptions = [ChoiceOptions]()
        var photos = [Photo]()
        for (index, image) in images.enumerated() {
            // Add the full image to the list of photos.
            let pollPicture = createPollPicturePhoto(pollId, image: image, index: index)
            photos.append(pollPicture)
            
            // Create a thumbnail image and add it to the photos list.
            let pollPictureThumbnail = createPollPictureThumbnailPhoto(pollId, image: image, index: index)
            photos.append(pollPictureThumbnail)
            
            // Append a new poll option using the image and thumbnail.
            let pollOption = ChoiceOptions(pollPictureId: pollPicture.id, pollPictureThumbnailId: pollPictureThumbnail.id)
            pollOptions.append(pollOption)
        }
        saveContext()
        
        // Create and save the poll.
        let poll = Choice(question: question, userId: YCDataModel.getUserId())
        if let profilePictureId = fetchUser()?.profilePictureId {
            poll.profilePictureId = profilePictureId
        }
        poll.pollOptions = pollOptions
        
        pollRef.setValue(poll.getPollData())
    }
    
    class func addMyPollsListObserver() {
        removePollListObserver()
        let myPolls = fireDatabase.child(FirebaseConstants.Polls)
        let myPollsQuery = myPolls.queryOrdered(byChild: FirebaseConstants.UserId).queryEqual(toValue: getUserId())
        observePollsList(myPollsQuery)
    }
    
    class func addAllPollsListObserver() {
        removePollListObserver()
        let allPolls = fireDatabase.child(FirebaseConstants.Polls)
        observePollsList(allPolls)
    }
    class func removePollListObserver() {
        let polls = fireDatabase.child(FirebaseConstants.Polls)
        polls.removeAllObservers()
    }
    
    class func observePollsList(_ query: FIRDatabaseQuery) {
        query.observe(.value, with: { snapshot in
            var polls = [Choice]()
            for snapshotItem in snapshot.children.allObjects.reversed() {
                let poll = Choice(snapshot: snapshotItem as! FIRDataSnapshot)
                polls.append(poll)
            }
            
            let userInfo = [NotificationData.Polls: polls]
            defaultCenter.post(name: Notification.Name(rawValue: NotificationNames.GetPollsCompleted), object: nil, userInfo: userInfo)
        })
    }
    class func addConnectionStateObserver() {
        let connectedRef = FIRDatabase.database().reference(withPath: FirebaseConstants.InfoConnected)
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                uploadLocalOnlyPhotos()
            }
        })
    }
    
    class func removeConnectionStateObserver() {
        let connectedRef = FIRDatabase.database().reference(withPath: FirebaseConstants.InfoConnected)
        connectedRef.removeAllObservers()
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
    
    fileprivate class func createPollPicturePhoto(_ pollId: String, image: UIImage, index: Int) -> Photo {
        let id = pollId + String(format: ImageConstants.PollPictureJPEG, index)
        return Photo(id: id, pollId: pollId, uploaded: false, isThumbnail: false, image: image, context: context)
    }
    
    fileprivate class func createPollPictureThumbnailPhoto(_ pollId: String, image: UIImage, index: Int) -> Photo {
        let targetSize = CGSize(width: ImageConstants.PollPictureThumbnailWidth, height: ImageConstants.PollPictureThumbnailHeight)
        let imageThumbnail = YCUtils.resizeImage(image, targetSize: targetSize)
        let id = pollId + String(format: ImageConstants.PollPictureThumbnailJPEG, index)
        return Photo(id: id, pollId: pollId, uploaded: false, isThumbnail: true, image: imageThumbnail, context: context)
    }
    
    fileprivate class func getProfilePictureId() -> String? {
        let user = fetchUser()!
        return user.profilePictureId
    }
    
    fileprivate class func getProfilePicture() -> Photo? {
        var photo: Photo?
        if let profilePictureId = getProfilePictureId() {
            photo = fetchPhotoById(profilePictureId)
        }
        
        return photo
    }
}
