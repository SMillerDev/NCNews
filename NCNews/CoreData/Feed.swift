//
//  Feed+CoreDataProperties.swift
//  
//
//  Created by Sean Molenaar on 13/01/2018.
//
//

import Foundation
import CoreData

class Feed: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged public var added: NSDate?
    @NSManaged public var faviconLink: String?
    @NSManaged public var id: Int64
    @NSManaged public var link: String?
    @NSManaged public var ordering: Int64
    @NSManaged public var pinned: Bool
    @NSManaged public var title: String?
    @NSManaged public var unreadCount: Int64
    @NSManaged public var url: String?
    @NSManaged public var folder: NSSet?
    @NSManaged public var items: NSSet?

    @objc(addFolderObject:)
    @NSManaged public func addToFolder(_ value: Folder)

    @objc(removeFolderObject:)
    @NSManaged public func removeFromFolder(_ value: Folder)

    @objc(addFolder:)
    @NSManaged public func addToFolder(_ values: NSSet)

    @objc(removeFolder:)
    @NSManaged public func removeFromFolder(_ values: NSSet)

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: FeedItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: FeedItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
