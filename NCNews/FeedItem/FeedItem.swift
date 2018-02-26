//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Sean Molenaar on 13/01/2018.
//
//

import Foundation
import CoreData
import PromiseKit

class FeedItem: NSManagedObject, NCNewsObject {
    static var dateSorted: Bool = true
    static var parentName: String? = "Feed"

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedItem> {
        return NSFetchRequest<FeedItem>(entityName: "FeedItem")
    }

    @NSManaged public var id: Int64
    @NSManaged public var guid: String?
    @NSManaged public var guidHash: String?
    @NSManaged public var fingerprint: String?
    @NSManaged public var contentHash: String?
    @NSManaged public var url: String?
    @NSManaged public var lead: String?
    @NSManaged public var image: String?
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var body: String?

    @NSManaged public var pubDate: NSDate?
    @NSManaged public var updateDate: NSDate?
    @NSManaged public var lastModified: NSDate?

    @NSManaged public var rtl: Bool
    @NSManaged public var unread: Bool
    @NSManaged public var starred: Bool

    @NSManaged public var parent: Feed

    func fill(with json: [String: Any]) {
        if let item = json["id"] as? NSNumber {
            self.id = item.int64Value
        }
        if let id = json["feedId"] as? NSNumber,
            let parent = DBManager.managedObject(id: id, context: self.managedObjectContext!, type: Feed.self, name: "Feed") {
            self.parent = parent
        }
        self.guid = json["guid"] as? String
        self.guidHash = json["guidHash"] as? String
        self.url = json["url"] as? String
        self.title = json["title"] as? String
        self.author = json["author"] as? String
        self.pubDate = json["pubDate"] as? NSDate
        self.updateDate = json["updateDate"] as? NSDate
        self.lastModified = json["lastModified"] as? NSDate
        self.unread = json["unread"] as? Bool ?? true
        self.starred = json["starred"] as? Bool ?? false
        self.rtl = json["rtl"] as? Bool ?? false
        self.fingerprint = json["fingerprint"] as? String
        self.contentHash = json["contentHash"] as? String
        self.body = json["body"] as? String
        self.lead = LeadFinder.find(body)
        if url == nil {
            self.image = ImageFinder.find(body, url: nil)?.absoluteString
        } else {
            self.image = ImageFinder.find(body, url: URL(string: url!))?.absoluteString
        }
    }
}
