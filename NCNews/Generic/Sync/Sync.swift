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

    internal func folders() {
        network.folders().done { folders in
            self.database.saveToDB(Folder.self, array: folders)
        }.catch { error in
            debugPrint(error.localizedDescription)
        }
    }

    internal func feeds() -> Promise<[NCNewsObject]> {
        return network.feeds().then { feeds in
            self.database.saveToDB(Feed.self, array: feeds)
        }
    }

    internal func items(_ range: FetchRange? = nil) {
        network.items(range).then { items in
            self.database.saveToDB(FeedItem.self, array: items)
        }.done { result in
            let count = Utils.getUnread(result)
            NotificationUtils.setBadgeIndicatorCount(count)
            print("## \(count) to show unread")
        }.catch { error in
            debugPrint(error.localizedDescription)
        }
    }

    func markRead(_ object: NCNewsObject?) {
        network.markRead(object).done { _ in
            self.database.markRead(object)
        }.catch { error in
            debugPrint(error.localizedDescription)
        }
    }
    
    func fetch<T: NCNewsObject>(_ type: T.Type) -> Promise<Any> {
        switch Utils.className(classType: type) {
        case Utils.className(classType: Feed.self):
            return .value(feeds())
        case Utils.className(classType: Folder.self):
            return .value(folders())
        case Utils.className(classType: FeedItem.self):
            return .value(items())
        default:
            return .value(items())
        }
    }
    
    func fullSync() {
        folders()
        feeds()
        items()
    }
    
    func refresh() {
        items(.unread).then {
            folders()
            }.then {
                feeds()
            }.then {
                items()
            }.done {
                print("Done refreshing")
        }
    }
}
