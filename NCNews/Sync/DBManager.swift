//
//  DBManager.swift
//  NCNews
//
//  Created by Sean Molenaar on 03/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import CoreData

class DBManager {
    let context: NSManagedObjectContext

    init() {
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }

    func markRead(_ object: NCNewsObject?, read: Bool = true) {
        if let folder = object as? Folder {
            folder.children?.forEach({ item in
                self.markRead(item as? NCNewsObject, read: read)
            })
        }
        if let feed = object as? Feed {
            feed.children?.forEach({ item in
                self.markRead(item as? NCNewsObject, read: read)
            })
            feed.unreadCount = 0
        }
        if let item = object as? FeedItem {
            item.unread = read
        }
        save()
    }

    func saveToDB(array: [NCNewsObject]?, name: String) {
        if array == nil {
            debugPrint("No value to store")
            return
        }
        array?.forEach({ object in
            context.insert(object as! NSManagedObject)
        })
        save()
    }

    fileprivate func save() {
        do {
            try context.save()
        } catch {
            print("❌ ERROR: Failed to save DB transacrion")
        }
    }
}
