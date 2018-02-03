//
//  NetworkManager.swift
//  NCNews
//
//  Created by Sean Molenaar on 11/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import Alamofire
import Sync

class NetworkManager {
    let baseUrl: URL

    let datastack: DataStack = DataStack()

    let sessionManager: SessionManager = {
        var conf = URLSessionConfiguration.ephemeral
        conf.requestCachePolicy = .useProtocolCachePolicy
        conf.timeoutIntervalForRequest = 200
        return SessionManager(configuration: conf, delegate: SessionDelegate(), serverTrustPolicyManager: nil)
    }()

    static let newsApiPath: String = "/index.php/apps/news/api/v1-2"

    init(_ url: URL, token: String) {
        baseUrl = url.appendingPathComponent(NetworkManager.newsApiPath)
        sessionManager.adapter = AccessTokenAdapter(accessToken: token)
        setup()
    }

    init(_ url: URL, user: String, pass: String) {
        baseUrl = url.appendingPathComponent(NetworkManager.newsApiPath)
        sessionManager.adapter = BasicAuthAdapter(user: user, password: pass)
        setup()
    }

    func setup() {
        // SETUP
    }

    func folders(_ completionHandler: @escaping ([Folder]) -> Void) {
        sessionManager.request(baseUrl.appendingPathComponent("/folders")).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                var newFolders: [Folder] = []
                let folders = json["folders"] as? [[String: Any]]
                folders?.forEach({ item in
                    let newItem = Folder()
                    newItem.fill(with: item)
                    newFolders.append(newItem)
                })
                completionHandler(newFolders)
            }
        }
    }

    func feeds(_ completionHandler: @escaping ([Feed]) -> Void) {
        sessionManager.request(baseUrl.appendingPathComponent("/feeds")).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                var newFeeds: [Feed] = []
                let feeds = json["feeds"] as? [[String: Any]]
                feeds?.forEach({ item in
                    let newItem = Feed()
                    newItem.fill(with: item)
                    newFeeds.append(newItem)
                })
                completionHandler(newFeeds)
            }
        }
    }

    func items(_ completionHandler: @escaping ([FeedItem]) -> Void, read: Bool = true, starred: Bool = false) {
        var param: Parameters = ["getRead": read, "type": 3]
        if starred {
            param["type"] = 2
        }
        sessionManager.request(baseUrl.appendingPathComponent("/items"), parameters: param).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                var newItems: [FeedItem] = []
                let items = json["items"] as? [[String: Any]]
                items?.forEach({ item in
                    let newItem: FeedItem = FeedItem()
                    newItem.fill(with: item)
                    newItems.append(newItem)
                })
                completionHandler(newItems)
            }
        }
    }

    func markRead(_ object: NCNewsObject?, read: Bool = true) {
        var ids: [Int64] = []
        if let item = object as? Folder {
            ids.append(contentsOf: item.childIDs())
        }
        if let item = object as? Feed {
            _ = item.children?.sorted(by: { old, new in old.pubDate?.compare(new.pubDate! as Date) == ComparisonResult.orderedDescending }).first
            ids.append(contentsOf: item.childIDs())
        }
        if let item = object as? FeedItem {
            ids = [item.id]
        }
        let url = read ? "/items/read/multiple" : "/items/unread/multiple"
        sessionManager.request(baseUrl.appendingPathComponent(url),
                               method: .put,
                               parameters: ["items": ids])
            .responseString { _ in }
    }

    func markStarred(_ object: NCNewsObject?, starred: Bool = true) {
        guard let item = object as? FeedItem else {
            return
        }
        if item.starred == starred {
            return
        }
        let url = starred ? "/items/star/multiple" : "/items/unstar/multiple"
        let params = ["items": [["feedId": String(item.parent!.id), "guidHash": item.guidHash]]]
        sessionManager.request(baseUrl.appendingPathComponent(url), method: .put, parameters: params)
                      .responseString { response in
            if response.error != nil {
                return
            }
            debugPrint(response.result.debugDescription)
        }
    }
}
