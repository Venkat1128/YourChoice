//
//  ChoiceOptions.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 17/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import Firebase
class ChoiceOptions{
    let DefaultVoteCount = 0
    
    var pollPictureId: String
    var pollPictureThumbnailId: String
    var voteCount: Int
    
    init(pollPictureId: String, pollPictureThumbnailId: String) {
        self.pollPictureId = pollPictureId
        self.pollPictureThumbnailId = pollPictureThumbnailId
        self.voteCount = DefaultVoteCount
    }
    
    init(snapshot: FIRDataSnapshot) {
        let voteCountNumber = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.VoteCount) as! NSNumber
        
        pollPictureId = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.PollPictureId) as! String
        pollPictureThumbnailId = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.PollPictureThumbnailId) as! String
        voteCount = Int(voteCountNumber)
    }
    
    func getPollOptionData() -> [String:AnyObject] {
        var data = [String: AnyObject]()
        data[FirebaseConstants.PollPictureId] = pollPictureId as AnyObject?
        data[FirebaseConstants.PollPictureThumbnailId] = pollPictureThumbnailId as AnyObject?
        data[FirebaseConstants.VoteCount] = voteCount as AnyObject?
        
        return data
    }
}
