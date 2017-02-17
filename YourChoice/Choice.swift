//
//  Choice.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 17/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import Firebase

class Choice{
    var id: String?
    var question: String
    var userId: String
    var selectedOption: String?
    var creationDate: Double
    var closed: Bool
    var photosUploaded: Bool
    var profilePictureId: String?
    var pollOptions = [ChoiceOptions]()
    
    init(question: String, userId: String) {
        self.question = question
        self.userId = userId
        self.creationDate = -YCUtils.getTimeIntervalSince1970()
        self.closed = false
        self.photosUploaded = false
    }
    
    init(snapshot: FIRDataSnapshot) {
        let closedNumber = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.Closed) as! NSNumber
        let photosUploadedNumber = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.PhotosUploaded) as! NSNumber
        let creationDateNumber = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.CreationDate) as! NSNumber
        
        id = snapshot.key
        question = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.Question) as! String
        userId = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.UserId) as! String
        selectedOption = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.SelectedOption) as? String
        profilePictureId = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.ProfilePictureId) as? String
        
        creationDate = Double(creationDateNumber)
        closed = Bool(closedNumber)
        photosUploaded = Bool(photosUploadedNumber)
        
        let pollOptionsSnapshot = snapshot.childSnapshot(forPath: FirebaseConstants.PollOptions)
        for index in 0..<pollOptionsSnapshot.childrenCount {
            let pollOptionSnapshot = pollOptionsSnapshot.childSnapshot(forPath: String(index))
            let pollOption = ChoiceOptions(snapshot: pollOptionSnapshot)
            pollOptions += [pollOption]
        }
    }
    
    func getPollData() -> [String:AnyObject] {
        var pollOptionsData = [[String:AnyObject]]()
        for pollOption in pollOptions {
            pollOptionsData.append(pollOption.getPollOptionData())
        }
        
        var data = [String: AnyObject]()
        data[FirebaseConstants.Question] = question as AnyObject?
        data[FirebaseConstants.UserId] = userId as AnyObject?
        data[FirebaseConstants.CreationDate] = creationDate as AnyObject?
        data[FirebaseConstants.Closed] = closed as AnyObject?
        data[FirebaseConstants.PhotosUploaded] = photosUploaded as AnyObject?
        data[FirebaseConstants.PollOptions] = pollOptionsData as AnyObject?
        if let profilePictureId = profilePictureId {
            data[FirebaseConstants.ProfilePictureId] = profilePictureId as AnyObject?
        }
        
        return data
    }

}
