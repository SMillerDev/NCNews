//
//  Feed+CoreDataProperties.swift
//  
//
//  Created by Sean Molenaar on 13/01/2018.
//
//

import Foundation
import CoreData

class Feed: NSManagedObject, NCNewsObject {
    static var dateSorted: Bool = false

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var added: NSDate?
    @NSManaged public var url: String?
    @NSManaged public var link: String?
    @NSManaged public var faviconLink: String?
    @NSManaged public var pinned: Bool
    @NSManaged public var ordering: Int64
    @NSManaged public var unreadCount: Int64
    @NSManaged public var parent: Folder?
    @NSManaged public var children: Set<FeedItem>?

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: FeedItem)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: FeedItem)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

    public class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    func childIDs() -> [Int64] {
        var ids: [Int64] = []
        self.children?.forEach({ item in
            ids.append(item.id)
        })
        return ids
    }

    func fill(with json: [String: AnyObject]) {
        if json.index(forKey: "id") != nil {
            self.id = json["id"] as! Int64
        }
        if json.index(forKey: "title") != nil {
            self.title = json["title"] as? String
        }
        if json.index(forKey: "added") != nil {
            self.added = json["added"] as? NSDate
        }
        if json.index(forKey: "url") != nil {
            self.url = json["url"] as? String
        }
        if json.index(forKey: "link") != nil {
            self.link = json["link"] as? String
        }
        if json.index(forKey: "faviconLink") != nil {
            self.faviconLink = json["faviconLink"] as? String
        }
        if json.index(forKey: "pinned") != nil {
            self.pinned = (json["pinned"] as? Bool) ?? false
        }
        if json.index(forKey: "ordering") != nil {
            self.ordering = json["ordering"] as? Int64 ?? 0
        }
        if let parent_id = json["folderId"] as? Int64 {
            do {
                self.parent = try self.managedObjectContext?.fetch(parent_id, inEntityNamed: "Folder")
            } catch {
                print("❌ ERROR: No folder found for feed \(parent_id)")
                self.parent = nil
            }
        }
    }
}
