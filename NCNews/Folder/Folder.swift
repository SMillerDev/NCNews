//
//  Folder+CoreDataProperties.swift
//  
//
//  Created by Sean Molenaar on 13/01/2018.
//
//

import Foundation
import CoreData

class Folder: NSManagedObject, NCNewsObject {
    static var parentName: String?
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var children: Set<Feed>?

    func childIDs() -> [Int64] {
        var ids: [Int64] = []
        self.children?.forEach({ item in
            ids.append(contentsOf: item.childIDs())
        })
        return ids
    }

    func getUnread() -> Int {
        var unread: Int = 0
        self.children?.forEach({ item in
            unread += item.getUnread()
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
        self.title = json["name"] as? String
    }
}
