//
//  DBManager.swift
//  NCNews
//
//  Created by Sean Molenaar on 03/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import CoreData
import PromiseKit

class DBManager {
    fileprivate let container: NSPersistentContainer

    init(_ container: NSPersistentContainer) {
        self.container = container
    }

    func markRead(_ object: NCNewsObject?, read: Bool = true) {
        container.performBackgroundTask { context in
            if let folder = object as? Folder {
                folder.children?.forEach({ item in
                    self.markRead(item as NCNewsObject, read: read)
                })
            }
            if let feed = object as? Feed {
                feed.children?.forEach({ item in
                    self.markRead(item as NCNewsObject, read: read)
                })
                feed.unreadCount = 0
            }
            if let item = object as? FeedItem {
                item.unread = read
            }
            self.save(context)
        }
    }

    func saveToDB<T: NSManagedObject>(_ type: T.Type, array: [[String: Any]]?) -> Promise<[NCNewsObject]> {
        if array == nil {
            debugPrint("No value to store")
            return .value([])
        }
        return Promise { seal in
            container.performBackgroundTask { context in
                let result: [NCNewsObject] = self.loop(type, array: array!, context: context)
                seal.fulfill(result)
            }
        }
    }

    internal func loop<T: NSManagedObject>(_ type: T.Type, array: [[String: Any]], context: NSManagedObjectContext) -> [NCNewsObject] {
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        context.automaticallyMergesChangesFromParent = true
        var result: [NCNewsObject] = []
        let name = Utils.className(classType: type)
        debugPrint("filling", array.count)
        for object in array {
            var newObject: NCNewsObject?
            if let item = DBManager.managedObject(id: object["id"] as! NSNumber, context: context, type: T.self, name: name) {
                newObject = item as? NCNewsObject
            } else {
                newObject = NSManagedObject(entity: T.entity(), insertInto: context) as? NCNewsObject
            }
            newObject!.fill(with: object)
            result.append(newObject!)
        }
        debugPrint("created/updated", array.count, name)
        self.save(context)
        return result
    }

    static func managedObject<T: NSManagedObject>(id: NSNumber, context: NSManagedObjectContext, type: T.Type, name: String? = nil) -> T? {
        let name: String = name == nil ? type.entity().name! : name!
        let fetchRequest = T.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%i", id.int64Value)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [T], let item = records.first {
                return item
            }
            debugPrint("'\(id)' not found for type \(name).")
        } catch {
            debugPrint("Error: '\(id)' could not be fetched for type \(name).")
        }
        return nil
    }

    /// Save all DB data
    fileprivate func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                context.processPendingChanges()
                context.refreshAllObjects()
            } catch {
                print("❌ ERROR: Failed to save DB transacrion \(error)")
            }
        }
    }
}
