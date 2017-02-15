//
//  User.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 15/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import CoreData
import Firebase

class User: NSManagedObject {

    static let EntityName = "User"
    
    @NSManaged var username: String
    @NSManaged var profilePictureId: String?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(snapshot: FIRDataSnapshot, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.username = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.Username) as! String
        self.profilePictureId = (snapshot.value! as AnyObject).object(forKey: FirebaseConstants.ProfilePictureId) as? String
    }
}
