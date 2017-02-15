//
//  Photo+CoreDataClass.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 15/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {

    static let EntityName = "Photo"
    
    @NSManaged var id: String
    @NSManaged var isThumbnail: Bool
    @NSManaged var pollId: String?
    @NSManaged var uploaded: Bool
    
    override func prepareForDeletion() {
        ImageCache.sharedInstance().deleteImage(id)
    }
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(id: String, pollId: String?, uploaded: Bool, isThumbnail: Bool, image: UIImage?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.id = id
        self.pollId = pollId
        self.uploaded = uploaded
        self.isThumbnail = isThumbnail
        self.image = image
    }
    
    var image: UIImage? {
        get {
            return ImageCache.sharedInstance().imageWithIdentifier(id)
        }
        
        set {
            ImageCache.sharedInstance().storeImage(newValue, withIdentifier: id)
        }
    }
    
    var path: String? {
        get {
            return ImageCache.sharedInstance().pathForIdentifier(id)
        }
    }
}
