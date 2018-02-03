//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Sean Molenaar on 13/01/2018.
//
//

import Foundation
import CoreData

class FeedItem: NSManagedObject, NCNewsObject {
    static var dateSorted: Bool = true
    fileprivate let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    init() {
        super.init(entity: NSEntityDescription.entity(forEntityName: "FeedItem", in: context)!, insertInto: context)
    }

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedItem> {
        return NSFetchRequest<FeedItem>(entityName: "FeedItem")
    }

    @NSManaged public var id: Int64
    @NSManaged public var guid: String?
    @NSManaged public var guidHash: String?
    @NSManaged public var url: String?
    @NSManaged public var lead: String?
    @NSManaged public var image: String?
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var pubDate: NSDate?
    @NSManaged public var updateDate: NSDate?
    @NSManaged public var lastModified: NSDate?
    @NSManaged public var body: String?
    @NSManaged public var unread: Bool
    @NSManaged public var starred: Bool
    @NSManaged public var rtl: Bool
    @NSManaged public var fingerprint: String?
    @NSManaged public var contentHash: String?
    @NSManaged public var parent: Feed?

    func fill(with json: [String: AnyObject]) {
        if let item = json["id"] as? Int64 {
            self.id = item
        }
        if json.index(forKey: "guid") != nil {
            self.guid = json["guid"] as? String
        }
        if json.index(forKey: "guidHash") != nil {
            self.guidHash = json["guidHash"] as? String
        }
        if json.index(forKey: "url") != nil {
            self.url = json["url"] as? String
        }
        if json.index(forKey: "title") != nil {
            self.title = json["title"] as? String
        }
        if json.index(forKey: "author") != nil {
            self.author = json["author"] as? String
        }
        if json.index(forKey: "pubDate") != nil {
            self.pubDate = json["pubDate"] as? NSDate
        }
        if json.index(forKey: "updateDate") != nil {
            self.updateDate = json["updateDate"] as? NSDate
        }
        if json.index(forKey: "lastModified") != nil {
            self.lastModified = json["lastModified"] as? NSDate
        }
        if json.index(forKey: "unread") != nil {
            self.unread = json["unread"] as? Bool ?? true
        }
        if json.index(forKey: "starred") != nil {
            self.starred = json["starred"] as? Bool ?? false
        }
        if json.index(forKey: "rtl") != nil {
            self.rtl = json["rtl"] as? Bool ?? false
        }
        if json.index(forKey: "fingerprint") != nil {
            self.fingerprint = json["fingerprint"] as? String
        }
        if json.index(forKey: "contentHash") != nil {
            self.contentHash = json["contentHash"] as? String
        }
        if let parent_id = json["feedId"] as? Int64 {
            do {
                self.parent = try self.managedObjectContext?.fetch(parent_id, inEntityNamed: "Folder")
            } catch {
                print("❌ ERROR: No feed found for item \(parent_id)")
                self.parent = nil
            }
        }

        self.lead = "Hello, this is a lead"
        self.image = "https://image.com"
    }
}
