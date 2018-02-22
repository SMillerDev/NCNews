//
//  Sync.swift
//  NCNews
//
//  Created by Sean Molenaar on 03/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//
import Foundation
import CoreData
import PromiseKit

class Sync {
    let network: NetworkManager
    let database: DBManager

    init(_ url: URL, container: NSPersistentContainer, token: String) {
        network = NetworkManager(url, container: container, token: token)
        database = DBManager(container)
    }
    init(_ url: URL, container: NSPersistentContainer, user: String, pass: String) {
        network = NetworkManager(url, container: container, user: user, pass: pass)
        database = DBManager(container)
    }

    func folders() {
        network.folders().done { folders in
            self.database.saveToDB(Folder.self, array: folders)
        }
    }

    func feeds() {
        network.feeds().done { feeds in
            self.database.saveToDB(Feed.self, array: feeds)
        }
    }

    func items() {
        network.items().done { items in
            self.database.saveToDB(FeedItem.self, array: items)
        }
    }

    func fullSync() {
        folders()
        feeds()
        items()
    }

    func markRead(_ object: NCNewsObject?) {
        network.markRead(object).done { _ in
            self.database.markRead(object)
        }
    }
}
