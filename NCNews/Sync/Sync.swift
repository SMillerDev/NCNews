//
//  Sync.swift
//  NCNews
//
//  Created by Sean Molenaar on 03/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//
import Foundation

class Sync {
    let network: NetworkManager
    let database: DBManager

    init(_ url: URL, token: String) {
        network = NetworkManager(url, token: token)
        database = DBManager()
    }
    init(_ url: URL, user: String, pass: String) {
        network = NetworkManager(url, user: user, pass: pass)
        database = DBManager()
    }

    func folders() {
        network.folders({ folders in
            self.database.saveToDB(array: folders, name: "Folder")
        })
    }

    func feeds() {
        network.folders({ feeds in
            self.database.saveToDB(array: feeds, name: "Feed")
        })
    }

    func items() {
        network.folders({ items in
            self.database.saveToDB(array: items, name: "FeedItem")
        })
    }

    func fullSync() {
        folders()
        feeds()
        items()
    }

    func markRead(_ object: NCNewsObject?) {
        network.markRead(object)
        database.markRead(object)
    }
}
