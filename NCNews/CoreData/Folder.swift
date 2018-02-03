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
    static var dateSorted: Bool = false
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

    func fill(with json: [String: AnyObject]) {
        if json.index(forKey: "id") != nil {
            self.id = (json["id"] as? Int64)!
        }
        if json.index(forKey: "name") != nil {
            self.title = json["name"] as? String
        }
    }
}
