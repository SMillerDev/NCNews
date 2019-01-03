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
    static var parentName: String? = "Folder"

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

    func getUnread() -> Int {
        var unread: Int = 0
        self.children?.forEach({ item in
            unread += item.unread ? 1 : 0
        })
        return unread
    }

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    func fill(with json: [String: Any]) {
        if let id = json["id"] as? NSNumber {
            self.id = id.int64Value
        }
        if let id = json["folderId"] as? NSNumber,
            id.intValue > 0,
            let parent = DBManager.managedObject(id: id, context: self.managedObjectContext!, type: Folder.self, name: "Folder") {
            self.parent = parent
        }
        self.title = json["title"] as? String
        self.added = json["added"] as? NSDate
        self.url = json["url"] as? String
        self.link = json["link"] as? String
        self.faviconLink = json["faviconLink"] as? String
        self.pinned = (json["pinned"] as? Bool) ?? false
        self.ordering = json["ordering"] as? Int64 ?? 0
    }
}
