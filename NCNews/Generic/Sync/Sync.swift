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

    func markRead(_ object: NCNewsObject?, status: Bool = true) {
        database.markRead(object).then { _ in
            return self.network.markRead(object)
        }.done { _ in
            NotificationUtils.badgeIndicatorCount -= 1
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
            return .value(items(.none))
        default:
            return .value(items(.none))
        }
    }

    func fullSync() {
        folders().then { _ in
            self.feeds()
        }.then { _ in
            self.items(.none)
        }.done { result in
            self.spotlightIndex(result)
            let count = Utils.getUnread(result)
            NotificationUtils.badgeIndicatorCount = count
            print("## \(count) to show unread")
        }.catch { error in
            debugPrint(error.localizedDescription)
        }
    }

    func refresh() -> Promise<Void> {
        DispatchQueue.global(qos: .background).async {
            self.fullSync()
        }

        return items(.unread).done { result in
            let count = Utils.getUnread(result)
            NotificationUtils.badgeIndicatorCount = count
            print("## \(count) to show unread")
        }
    }

    internal func folders() -> Promise<[NCNewsObject]> {
        return network.folders().then { folders in
            self.database.saveToDB(Folder.self, array: folders)
        }
    }

    internal func feeds() -> Promise<[NCNewsObject]> {
        return network.feeds().then { feeds in
            self.database.saveToDB(Feed.self, array: feeds)
        }
    }

    internal func items(_ range: FetchRange) -> Promise<[NCNewsObject]> {
        return network.items(range).then { items in
            self.database.saveToDB(FeedItem.self, array: items)
        }
    }
}
