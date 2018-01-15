//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Sean Molenaar on 13/01/2018.
//
//

import Foundation
import CoreData

class FeedItem: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedItem> {
        return NSFetchRequest<FeedItem>(entityName: "FeedItem")
    }

    @NSManaged public var id: Int64
    @NSManaged public var guid: String?
    @NSManaged public var guidHash: String?
    @NSManaged public var url: String?
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var pubDate: NSDate?
    @NSManaged public var updateDate: NSDate?
    @NSManaged public var body: String?
    @NSManaged public var unread: Bool
    @NSManaged public var starred: Bool
    @NSManaged public var lastModified: NSDate?
    @NSManaged public var rtl: Bool
    @NSManaged public var fingerprint: String?
    @NSManaged public var contentHash: String?
    @NSManaged public var feed: Feed?

}
